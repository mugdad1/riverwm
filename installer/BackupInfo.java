public class BackupInfo {
    private int id;
    private String filename;
    private String backupPath;
    private int version;
    private String backedUpAt;

    public BackupInfo() {
    }

    public BackupInfo(int id, String filename, String backupPath, int version, String backedUpAt) {
        this.id = id;
        this.filename = filename;
        this.backupPath = backupPath;
        this.version = version;
        this.backedUpAt = backedUpAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public String getBackupPath() {
        return backupPath;
    }

    public void setBackupPath(String backupPath) {
        this.backupPath = backupPath;
    }

    public int getVersion() {
        return version;
    }

    public void setVersion(int version) {
        this.version = version;
    }

    public String getBackedUpAt() {
        return backedUpAt;
    }

    public void setBackedUpAt(String backedUpAt) {
        this.backedUpAt = backedUpAt;
    }

    @Override
    public String toString() {
        return "v" + version + " - " + backedUpAt;
    }
}
