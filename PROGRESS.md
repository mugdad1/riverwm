# Progress Notes - 2026-04-26

## Simplification: Removed Symlink Handling from FileOverwriteUI

### Decision
User requested simple file copy behavior (`cp`-style) - no symlink handling at all.

### Changes Made
Reverted `/home/void/riverwm/installer/FileOverwriteUI.java` to use basic `Files.copy()` with `StandardCopyOption.REPLACE_EXISTING` only (no `NOFOLLOW_LINKS`).

This means:
- Symlinks in source will be copied as symlinks (default Java behavior)
- Target symlinks will be replaced normally

### Files Modified
- `installer/FileOverwriteUI.java`

### Status
- [x] Simplified copy operations to basic cp-style behavior