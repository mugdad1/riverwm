import java.io.File;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class DatabaseManager {
    private static DatabaseManager instance;
    private static final String DB_DIR = System.getProperty("user.home") + "/.config/river/backups";
    private static final String DB_PATH = DB_DIR + "/backups.db";

    private DatabaseManager() {
        initializeDatabase();
    }

    public static synchronized DatabaseManager getInstance() {
        if (instance == null) {
            instance = new DatabaseManager();
        }
        return instance;
    }

    private void initializeDatabase() {
        try {
            File dbDir = new File(DB_DIR);
            if (!dbDir.exists()) {
                dbDir.mkdirs();
            }

            Connection conn = DriverManager.getConnection("jdbc:sqlite:" + DB_PATH);
            Statement stmt = conn.createStatement();

            String createTableSQL = """
                CREATE TABLE IF NOT EXISTS config_backups (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    filename TEXT NOT NULL,
                    backup_path TEXT NOT NULL,
                    version INTEGER NOT NULL,
                    backed_up_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
                """;
            stmt.execute(createTableSQL);

            stmt.close();
            conn.close();
        } catch (SQLException e) {
            System.err.println("Database initialization error: " + e.getMessage());
        }
    }

    public String saveBackup(String filename, String sourcePath) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DriverManager.getConnection("jdbc:sqlite:" + DB_PATH);

            int currentVersion = getNextVersion(filename);

            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss"));
            String backupDirName = filename + "_v" + currentVersion + "_" + timestamp;
            String backupPath = DB_DIR + "/" + backupDirName;

            new File(backupPath).mkdirs();

            stmt = conn.prepareStatement(
                "INSERT INTO config_backups (filename, backup_path, version) VALUES (?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS
            );
            stmt.setString(1, filename);
            stmt.setString(2, backupPath);
            stmt.setInt(3, currentVersion);

            stmt.executeUpdate();

            ResultSet rs = stmt.getGeneratedKeys();
            int backupId = 0;
            if (rs.next()) {
                backupId = rs.getInt(1);
            }
            rs.close();

            return backupPath;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    private int getNextVersion(String filename) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DriverManager.getConnection("jdbc:sqlite:" + DB_PATH);

            stmt = conn.prepareStatement(
                "SELECT MAX(version) as max_version FROM config_backups WHERE filename = ?"
            );
            stmt.setString(1, filename);

            rs = stmt.executeQuery();

            if (rs.next() && rs.getObject("max_version") != null) {
                return rs.getInt("max_version") + 1;
            }
            return 1;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public List<BackupInfo> getVersions(String filename) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DriverManager.getConnection("jdbc:sqlite:" + DB_PATH);

            stmt = conn.prepareStatement(
                "SELECT id, filename, backup_path, version, backed_up_at FROM config_backups WHERE filename = ? ORDER BY version DESC"
            );
            stmt.setString(1, filename);

            rs = stmt.executeQuery();

            List<BackupInfo> backups = new ArrayList<>();
            while (rs.next()) {
                BackupInfo info = new BackupInfo(
                    rs.getInt("id"),
                    rs.getString("filename"),
                    rs.getString("backup_path"),
                    rs.getInt("version"),
                    rs.getString("backed_up_at")
                );
                backups.add(info);
            }

            return backups;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public List<String> getAllBackupFilenames() throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DriverManager.getConnection("jdbc:sqlite:" + DB_PATH);

            stmt = conn.prepareStatement(
                "SELECT DISTINCT filename FROM config_backups ORDER BY filename"
            );

            rs = stmt.executeQuery();

            List<String> filenames = new ArrayList<>();
            while (rs.next()) {
                filenames.add(rs.getString("filename"));
            }

            return filenames;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    public static String getBackupDir() {
        return DB_DIR;
    }
}
