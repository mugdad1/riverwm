# Void Linux System Tools - Usage Documentation

## Files Overview

### 1. VoidLauncher.java
Main menu - launches other apps as separate processes.

**Key Functions:**
- `VoidLauncher()` - Creates main window with 3 buttons
- `getClassPath()` - Builds classpath with lib/*.jar
- `launchAppThreaded()` - Launches with pkexec (Service Manager, Package Installer)
- `launchAppWithoutSudo()` - Launches without pkexec (FileOverwriteUI)

### 2. ServiceManagerApp.java
Manages runit services (start/stop/enable/disable).

**Key Functions:**
- `fetchServices()` - Lists /etc/sv/* (available services)
- `isServiceEnabled()` - Checks if symlink exists in /var/service/
- `performServiceChanges()` - Runs `sv up/down`, `ln -sf`, `rm` commands
- `runPkexecCommand()` - Runs command with root via pkexec

### 3. PackageInstallerApp.java
Search and install Void Linux packages via xbps.

**Key Functions:**
- `performSearch()` - Runs `xbps-query -R -s <query>`
- `runPackageAction()` - Runs `xbps-install -Sy` or `xbps-remove -Ry`
- `refreshInstalled()` - Runs `xbps-query -l`

### 4. FileOverwriteUI.java
Backup and restore configs from ~/riverwm/ to ~/.config/.

**Key Functions:**
- `overwriteFiles()` - Main backup+overwrite logic
- `copyDirectory()` - Recursive copy, EXCLUDES "backups" folder
- `copyToBackup()` - Copies current config to backup
- `deleteDirectory()` - Recursive delete
- `openRestoreDialog()` - Opens backup history

### 5. DatabaseManager.java
Singleton - SQLite database for backup metadata.
DB Location: `~/.config/backups/backups.db`

**Key Functions:**
- `getInstance()` - Returns singleton instance
- `initializeDatabase()` - Creates DB + table
- `saveBackup()` - Creates backup, returns path, inserts to DB
- `getVersions()` - SELECT * FROM config_backups WHERE filename=?
- `getAllBackupFilenames()` - SELECT DISTINCT filename
- `deleteOldBackups()` - Deletes old backups before new one

**Table Schema:**
```sql
config_backups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT NOT NULL,
    backup_path TEXT NOT NULL,
    version INTEGER NOT NULL,
    backed_up_at TIMESTAMP
)
```

### 6. BackupInfo.java
Simple data class with fields: id, filename, backupPath, version, backedUpAt

### 7. BackupHistoryDialog.java
Dialog to view and restore backups.

**Key Functions:**
- `loadBackups()` - Gets versions from DB, displays in table
- `restoreSelected()` - Copies backup to ~/.config/

## How Backup Works

```
User clicks "Overwrite Selected"
    └─> FileOverwriteUI.overwriteFiles()
        └─> dbManager.deleteOldBackups()      (DELETE old backups from DB + filesystem)
        └─> dbManager.saveBackup()            (Create backup dir, INSERT to DB)
        └─> copyToBackup()                    (Copy current ~/.config/X to backup/)
        └─> copyDirectory()                   (Copy new ~/riverwm/X to ~/.config/)
            (skips "backups" folder!)
```

## How Restore Works

```
User clicks "Restore"
    └─> FileOverwriteUI.openRestoreDialog()
        └─> BackupHistoryDialog.show()
        └─> User selects backup version
        └─> restoreSelected()
            └─> deleteDirectory()            (Delete current ~/.config/X)
            └─> copyDirectory()              (Copy backup/ to ~/.config/)
                (skips "backups" folder!)
```

## Commands

### Compile
```bash
cd ~/riverwm/installer
javac -cp "lib/sqlite-jdbc-3.51.3.0.jar:." *.java
```

### Run
```bash
# With wrapper (for riverwm/sway)
./java-awt-wm-noreparenting java -cp "lib/sqlite-jdbc-3.51.3.0.jar:." VoidLauncher

# Or with env var
_JAVA_OPTIONS="--enable-native-access=ALL-UNNAMED" \
  _JAVA_AWT_WM_NONREPARENTING=1 java -cp "lib/sqlite-jdbc-3.51.3.0.jar:." VoidLauncher

# Run in background
nohup ./java-awt-wm-noreparenting java -cp "lib/sqlite-jdbc-3.51.3.0.jar:." VoidLauncher &
```

### Check DB
```bash
sqlite3 ~/.config/backups/backups.db "SELECT * FROM config_backups;"
```

## Windows 11

**Works:**
- VoidLauncher, FileOverwriteUI, DatabaseManager (with path changes)
- SQLite JDBC driver

**Won't Work:**
- ServiceManagerApp (uses /etc/sv/ and runit)
- PackageInstallerApp (uses xbps)

**Path Changes Needed:**
- Change `/etc/sv/` and `/var/service/` to Windows paths
- Change `~/.config/` to Windows equivalent

## Wrapper Script (java-awt-wm-noreparenting)

```sh
#!/bin/sh
export _JAVA_AWT_WM_NONREPARENTING=1
exec "$@"
```

Tells Java AWT to work with non-reparenting window managers (riverwm, sway, i3).

## Fixes Applied

1. **Excludes "backups" folder** - Prevents infinite nesting when backing up configs that already contain backups
2. **Deletes old backups before new** - Saves space
3. **DB moved to ~/.config/backups/** - Separates from config backups
4. **Direct path mapping** - Each config maps to ~/.config/configname (not inside ~/.config/river/)