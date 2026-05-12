# RiverWM Installer - UI Layout Documentation

Total Lines of Code: **1229** across 7 Java files

---

## 1. VoidLauncher.java (150 LOC)
**Purpose:** Main launcher window providing entry point to all tools

### Layout Structure
- **Root Layout:** `BorderLayout(10, 10)` with `EmptyBorder(20, 20, 20, 20)`
- **Window Size:** 350x200, fixed (non-resizable)

| Region | Component | Description |
|--------|-----------|-------------|
| **NORTH** | `JLabel` - "System Tools" | Centered title, Monospaced Bold 16pt |
| **CENTER** | `JPanel` with `GridLayout(3, 1, 0, 10)` | 3 buttons vertically stacked with 10px spacing |
| **SOUTH** | `JLabel` - Status bar | "Ready" text, Monospaced 10pt, gray color |

### Button Panel (GridLayout 3x1)
1. **Service Manager** - Launches `ServiceManagerApp` with sudo
2. **Package Installer** - Launches `PackageInstallerApp` with sudo
3. **FileOverwriteUI** - Launches without sudo

### Key Features
- Uses `ProcessBuilder` to spawn new JVM processes for each app
- Sets `DISPLAY` and `_JAVA_AWT_WM_NONREPARENTING=1` for River WM compatibility
- Status label shows launch progress
- All buttons use Monospaced Plain 12pt font

---

## 2. ServiceManagerApp.java (173 LOC)
**Purpose:** Manage Void Linux services (enable/disable)

### Layout Structure
- **Root Layout:** `BorderLayout(10, 10)`
- **Window Size:** 1000x700

| Region | Component | Description |
|--------|-----------|-------------|
| **CENTER** | `JPanel` - Service Panel | `GridLayout(1, 3, 10, 10)` with titled border "Manage Services" |
| **SOUTH** | `JPanel` - Control Panel | `BorderLayout` with log area and apply button |

### Service Panel (GridLayout 1x3)
| Column | Component | Layout |
|--------|-----------|--------|
| **Left** | Disabled Services `JList` | `BorderLayout`: North=Label, Center=`JScrollPane` |
| **Center** | Button Panel | `GridLayout(0, 1, 5, 5)` with "Enable >" and "< Disable" buttons |
| **Right** | Enabled Services `JList` | `BorderLayout`: North=Label, Center=`JScrollPane` |

### Control Panel (BorderLayout)
- **Center:** `JTextArea` (10 rows, Monospaced 11pt) in `JScrollPane` - shows operation log
- **South:** "Apply Service Changes" button

### Data Models
- `DefaultListModel<String>` for disabled and enabled service lists
- Services populated from `/etc/sv/` (available) and `/var/service/` (enabled)

---

## 3. PackageInstallerApp.java (196 LOC)
**Purpose:** Search and install/remove Void Linux packages

### Layout Structure
- **Root Layout:** `BorderLayout`
- **Window Size:** 1000x700

| Region | Component | Description |
|--------|-----------|-------------|
| **NORTH** | `JPanel` - Search Panel | `BorderLayout` with label, text field, and buttons |
| **CENTER** | `JScrollPane` | Contains `JTable` for package search results |
| **SOUTH** | `JScrollPane` | Contains `JTextArea` for operation log |

### Search Panel (BorderLayout)
| Region | Component | Description |
|--------|-----------|-------------|
| **WEST** | `JLabel` - "Search Packages:" | Static label |
| **CENTER** | `JTextField` | Search input with 300ms debounce timer |
| **EAST** | `JPanel` | Contains "Install Selected" and "Uninstall Selected" buttons |

### Package Table (`JTable` with `DefaultTableModel`)
| Column | Type | Editable |
|--------|------|----------|
| Package | String | No |
| Description | String | No |
| Installed? | String ("Yes"/"No") | No |
| Select | Boolean (checkbox) | Yes |

### Key Features
- Uses `SwingWorker` for background package operations
- `xbps-query -l` to get installed packages
- `xbps-query -R -s` for repository search
- `pkexec` for privileged operations

---

## 4. FileOverwriteUI.java (250 LOC)
**Purpose:** Overwrite River WM configs from ~/riverwm to ~/.config

### Layout Structure
- **Root Layout:** `BorderLayout(10, 10)` with `EmptyBorder(10, 10, 10, 10)`
- **Window Size:** 700x550

| Region | Component | Description |
|--------|-----------|-------------|
| **NORTH** | `JPanel` - Info Panel | `GridLayout(3, 1, 5, 5)` showing paths |
| **CENTER** | `JScrollPane` | `JList` for file selection (multiple interval) |
| **SOUTH** | `JPanel` - Bottom Panel | `BorderLayout` with buttons and status |

### Info Panel (GridLayout 3x1)
1. **Title Label:** "Select River WM configs to overwrite in ~/.config/"
2. **Source Label:** "Source: ~/riverwm"
3. **Target Label:** "Target: ~/.config"

### File List (Center)
- `JList<String>` with `DefaultListModel`
- Multiple interval selection enabled
- Monospaced 12pt font
- Directories displayed with "/" suffix

### Bottom Panel (BorderLayout)
| Region | Component | Description |
|--------|-----------|-------------|
| **NORTH** | `JPanel` - Button Panel | `FlowLayout(RIGHT)` with 4 buttons |
| **WEST** | `JLabel` - "Status:" | Static label |
| **CENTER** | `JScrollPane` | `JTextArea` (5 rows) for status messages |

### Button Panel (FlowLayout RIGHT)
1. **Refresh** - Reloads file list
2. **Restore** - Opens `BackupHistoryDialog`
3. **Overwrite Selected** - Copies files to ~/.config
4. **Exit** - Closes application

### Key Features
- Uses `DatabaseManager` for backup operations
- Creates `~/.config/fish/` and `~/.config/river/` directories
- Backs up existing files before overwriting
- Recursive directory copy support

---

## 5. BackupHistoryDialog.java (161 LOC)
**Purpose:** Modal dialog showing backup versions for a config file

### Layout Structure
- **Root Layout:** `BorderLayout(10, 10)`
- **Window Size:** 500x350
- **Type:** `JDialog` (modal, blocks parent)

| Region | Component | Description |
|--------|-----------|-------------|
| **NORTH** | `JLabel` - Title | "Backup History: " + filename, Bold 14pt |
| **CENTER** | `JScrollPane` | `JTable` showing version history |
| **SOUTH** | `JPanel` - Button Panel | `FlowLayout(RIGHT)` with action buttons |

### Backup Table (`JTable` with `DefaultTableModel`)
| Column | Type | Editable |
|--------|------|----------|
| Version | String ("v1", "v2", etc.) | No |
| Date | String (timestamp) | No |

### Button Panel (FlowLayout RIGHT)
1. **Restore Selected** - Restores chosen backup version
2. **Cancel** - Closes dialog

### Key Features
- Double-click on table row triggers restore
- Shows confirmation dialog before restoring
- Deletes current config before restoring backup
- Uses `DatabaseManager.getVersions()` to load backup history

---

## 6. DatabaseManager.java (236 LOC)
**Purpose:** SQLite database manager for backup metadata (No UI)

### Database Location
- Directory: `~/.config/backups/`
- File: `backups.db`

### Table Schema: `config_backups`
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PRIMARY KEY | Auto-increment ID |
| filename | TEXT NOT NULL | Config file name |
| backup_path | TEXT NOT NULL | Full path to backup directory |
| version | INTEGER NOT NULL | Backup version number |
| backed_up_at | TIMESTAMP | Auto-generated timestamp |

### Key Methods
- `saveBackup()` - Saves backup metadata, returns backup path
- `getVersions()` - Returns all versions for a filename
- `getAllBackupFilenames()` - Returns distinct filenames with backups
- `deleteOldBackups()` - Removes all backups for a filename

---

## 7. BackupInfo.java (63 LOC)
**Purpose:** Data model class for backup information (No UI)

### Fields
| Field | Type | Description |
|-------|------|-------------|
| id | int | Database ID |
| filename | String | Config file name |
| backupPath | String | Backup directory path |
| version | int | Version number |
| backedUpAt | String | Timestamp string |

### Key Methods
- `toString()` returns `"v" + version + " - " + backedUpAt"`

---

## Summary: UI Organization

```
VoidLauncher (Main Menu)
├── BorderLayout
│   ├── NORTH: Title
│   ├── CENTER: 3 Buttons (GridLayout 3x1)
│   └── SOUTH: Status bar
│
├── ServiceManagerApp (Service Management)
│   ├── BorderLayout
│   │   ├── CENTER: Service Panel (GridLayout 1x3)
│   │   │   ├── Disabled List (BorderLayout)
│   │   │   ├── Enable/Disable Buttons (GridLayout)
│   │   │   └── Enabled List (BorderLayout)
│   │   └── SOUTH: Control Panel (BorderLayout)
│   │       ├── Log Area (Center)
│   │       └── Apply Button (South)
│
├── PackageInstallerApp (Package Management)
│   ├── BorderLayout
│   │   ├── NORTH: Search Panel (BorderLayout)
│   │   │   ├── Label (West)
│   │   │   ├── TextField (Center)
│   │   │   └── Buttons (East)
│   │   ├── CENTER: Package Table (JScrollPane)
│   │   └── SOUTH: Log Area (JScrollPane)
│
└── FileOverwriteUI (Config Overwrite)
    ├── BorderLayout
    │   ├── NORTH: Info Panel (GridLayout 3x1)
    │   ├── CENTER: File List (JScrollPane)
    │   └── SOUTH: Bottom Panel (BorderLayout)
    │       ├── Button Panel (North - FlowLayout)
    │       └── Status Area (Center - JScrollPane)
    │
    └── BackupHistoryDialog (Modal)
        ├── BorderLayout
        │   ├── NORTH: Title Label
        │   ├── CENTER: Backup Table (JScrollPane)
        │   └── SOUTH: Button Panel (FlowLayout)
```

---

## Common UI Patterns

1. **Layout Manager Usage:**
   - `BorderLayout` - Main window layout (5/5 UI classes)
   - `GridLayout` - Button groups and multi-column panels
   - `FlowLayout` - Button panels with natural flow

2. **Font Convention:**
   - Titles: Dialog/Monospaced Bold 14-16pt
   - Body: Monospaced Plain 11-12pt
   - Status: Monospaced Plain 10pt

3. **Scroll Pane Usage:**
   - All lists and text areas wrapped in `JScrollPane`
   - Consistent border spacing with `EmptyBorder` or `BorderFactory`

4. **Color Scheme:**
   - Status text: Gray (100, 100, 100)
   - System default for other components

5. **Threading:**
   - `SwingUtilities.invokeLater()` for EDT compliance
   - `SwingWorker` for background tasks (PackageInstallerApp)
   - Separate threads for launching apps (VoidLauncher)
