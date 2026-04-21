# Full Plan: Config Backup/Version with JDBC

---

## Overview
Add versioned backup system to FileOverwriteUI using SQLite JDBC. Before overwriting a config file, save backup to disk and store metadata in SQLite DB. User can restore previous versions.

---

## Database

### Table: `config_backups`
```sql
CREATE TABLE config_backups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT NOT NULL,
    backup_path TEXT NOT NULL,
    version INTEGER NOT NULL,
    backed_up_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Backup Directory
```
~/.config/river/backups/
├── init_v1_2024-04-21_10-30-00
├── init_v2_2024-04-20_15-22-00
├── keymap_v1_2024-04-19_08-00-00
```

---

## JDBC Operations (5 Steps Required)

### 1. Save Backup (INSERT)
```java
// Step 1: Establish connection
Connection conn = DriverManager.getConnection("jdbc:sqlite:" + DB_PATH);

// Step 2: Create statement
PreparedStatement stmt = conn.prepareStatement(
    "INSERT INTO config_backups (filename, backup_path, version) VALUES (?, ?, ?)"
);
stmt.setString(1, filename);
stmt.setString(2, backupPath);
stmt.setInt(3, version);

// Step 3: Execute query
stmt.executeUpdate();

// Step 4: Process ResultSet (not needed for INSERT)

// Step 5: Close connection
stmt.close();
conn.close();
```

### 2. Get Version History (SELECT)
```java
// Step 1: Establish connection
Connection conn = DriverManager.getConnection("jdbc:sqlite:" + DB_PATH);

// Step 2: Create statement
PreparedStatement stmt = conn.prepareStatement(
    "SELECT version, backed_up_at FROM config_backups WHERE filename = ? ORDER BY version DESC"
);
stmt.setString(1, filename);

// Step 3: Execute query
ResultSet rs = stmt.executeQuery();

// Step 4: Process ResultSet
List<BackupInfo> backups = new ArrayList<>();
while (rs.next()) {
    BackupInfo info = new BackupInfo(
        rs.getInt("version"),
        rs.getString("backed_up_at")
    );
    backups.add(info);
}

// Step 5: Close connection
rs.close();
stmt.close();
conn.close();
```

### 3. Get Backup Content (SELECT + File I/O)
```java
// Steps 1-4: Get backup_path from DB
// Step 5: Read file content from backup_path
String content = Files.readString(Path.of(backupPath));
```

---

## Files to Create/Modify

### 1. New: `DatabaseManager.java`
- Singleton class
- DB connection management
- Methods: saveBackup(), getVersions(), getBackupContent(), deleteOldBackups()

### 2. New: `BackupInfo.java` (Model class)
```java
public class BackupInfo {
    private int version;
    private String date;
    private String filename;
    private String backupPath;
    
    // Constructors
    // Getters and Setters
}
```

### 3. Modify: `FileOverwriteUI.java`
- Add "Restore" button
- Before overwrite: call saveBackup()
- Show backup indicator in status

### 4. New: `BackupHistoryDialog.java`
- Shows list of past versions
- "Restore" button for each version

---

## Dependencies

### Maven (pom.xml)
```xml
<dependency>
    <groupId>org.xerial</groupId>
    <artifactId>sqlite-jdbc</artifactId>
    <version>3.51.1.1</version>
</dependency>
```

**Note:** Latest version is **3.51.3.0** (March 2026), but **3.51.1.1** is more stable.

---

## Implementation Order

| Step | Task |
|------|------|
| 1 | Create BackupInfo.java (model class) |
| 2 | Create DatabaseManager.java (JDBC operations) |
| 3 | Test JDBC connection works |
| 4 | Modify FileOverwriteUI - add backup before overwrite |
| 5 | Create BackupHistoryDialog.java |
| 6 | Add "Restore" button to FileOverwriteUI |
| 7 | Test full flow: backup → copy → restore |

---

## UI Changes

### FileOverwriteUI (Current)
- File list (JList)
- Overwrite Selected button
- Refresh button
- Status area

### FileOverwriteUI (New)
- File list (JList)
- **Restore button** (NEW)
- Overwrite Selected button (now auto-backs up first)
- Refresh button
- Status area (shows backup info)

### BackupHistoryDialog (NEW)
- Table: Version | Date
- Buttons: "Restore Selected", "Cancel"
- Double-click row to restore

---

## Key Points for OOP2

1. **Model-View-Controller** - BackupInfo (Model), Dialogs (View), DatabaseManager (Controller)
2. **JDBC 5 steps** - All 5 steps used in save/get operations
3. **Exception handling** - try-catch for DB errors
4. **PreparedStatement** - Prevents SQL injection

---