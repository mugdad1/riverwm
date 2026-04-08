# River WM Configuration

A comprehensive River window manager setup targeting **Void Linux** with XBPS package manager.

## Overview

This is a personal configuration for [River](https://github.com/riverwm/river), a dynamic tiling Wayland compositor. The setup emphasizes minimalism, Gruvbox theming, and efficient keyboard-driven workflows.

**Platform:** Void Linux | **Theme:** Gruvbox Dark | **Shell:** Fish | **Font:** JetBrains Mono Nerd Font

---

## Directory Structure

```
riverwm/
├── init                    # River startup entry point (sources all configs)
├── options                 # Input devices, window rules, keyboard layout
├── keymap                  # All keybindings (organized by function)
├── autostart               # Programs launched on startup
├── rivertile               # Default layout generator config
├── rivercarro              # Alternative layout generator
├── wideriver               # Custom layout generator (toggle + monocle)
├── bg.jpg                  # Wallpaper image
├── install.bash            # Main installation script
├── alacritty/              # Terminal config (TOML)
├── waybar/                 # Status bar (JSON + CSS)
├── wofi/                   # Application launcher
├── mako/                   # Notification daemon
├── scripts/                # Helper scripts for keybindings
├── setup/                  # Modular installation scripts
├── installer/              # Java GUI tools for Void Linux
└── fish/                   # Fish shell configuration
```

---

## Configuration Files

### Core River Files

| File | Purpose |
|------|---------|
| `init` | Entry point - sources autostart → options → keymap → rivertile → scripts/* |
| `options` | Input devices (touchpad, keyboard), window rules, float windows |
| `keymap` | All keybindings organized by function (media, tags, apps, layout, etc.) |
| `autostart` | Startup programs: wallpaper, waybar, mako, polkit agent |
| `rivertile` | Default tiling layout generator (split ratio, main count/position) |
| `wideriver` | Alternative layout with toggle support and monocle mode |
| `rivercarro` | Simpler layout variant |

### Component Configs

| Component | Config Path | Format |
|-----------|-------------|--------|
| Terminal | `alacritty/alacritty.toml` | TOML |
| Status Bar | `waybar/config` | JSON |
| Bar Styles | `waybar/style.css` | CSS |
| Launcher | `wofi/config` | Config |
| Launcher Styles | `wofi/style.css` | CSS |
| Notifications | `mako/config` | Config |

---

## Keybindings

### Prefix: `Super` (Windows key)

### Media Controls (work in all modes)
| Key | Action |
|-----|--------|
| `Super+VolumeUp/Down` | Volume adjust ±5 |
| `Super+M` | Mute toggle |
| `Super+Media` | Play/Pause (playerctl) |
| `Super+Next/Prev` | Next/Previous track |
| `Super+BrightnessUp/Down` | Screen brightness ±5% |

### Tag Management (7 tags)
| Key | Action |
|-----|--------|
| `Super+[1-7]` | Focus tag |
| `Super+Shift+[1-7]` | Send to tag |
| `Super+Control+[1-7]` | Toggle tag focus |
| `Super+Shift+Control+[1-7]` | Toggle tag view |

### Applications
| Key | Action |
|-----|--------|
| `Super+Return` | Alacritty (normal) |
| `Super+Shift+Return` | Alacritty (floating) |
| `Super+B` | LibreWolf browser |
| `Super+Y` | Yazi file manager |
| `Super+D` | Wofi application launcher |
| `Super+V` | Clipboard manager (cliphist + wofi) |
| `Super+L` | Lock screen (swaylock) |
| `Super+Q` | Close focused view |
| `Print` | Screenshot (grim + slurp) |

### Layout Navigation
| Key | Action |
|-----|--------|
| `Super+J/K` | Focus next/previous view |
| `Super+H/L` | Focus left/right |
| `Super+Shift+J/K` | Swap next/previous view |
| `Super+Shift+H/L` | Swap left/right |
| `Super+M` | Zoom (bump view to top) |
| `Super+Period/Comma` | Focus next/prev output |
| `Super+Shift+Period/Comma` | Send to next/prev output |
| `Super+F` | Toggle fullscreen |
| `Super+Shift+F` | Toggle float |

### Rivertile Layout (main ratio adjuster)
| Key | Action |
|-----|--------|
| `Super+H/L` | Adjust main ratio ±0.02 |
| `Super+Shift+H/L` | Adjust main count ±1 |
| `Super+Control+H/J/K/L` | Change main position |

### Wideriver Layout (when active)
| Key | Action |
|-----|--------|
| `Super+Space` | Toggle between layouts |
| `Super+Plus/Equal/Minus` | Adjust ratio |

### Pointer Bindings
| Key | Action |
|-----|--------|
| `Super+Left Mouse` | Move view |
| `Super+Right Mouse` | Resize view |
| `Super+Middle Mouse` | Toggle float |

### Other
| Key | Action |
|-----|--------|
| `Super+R` | Reload configuration |
| `Super+Shift+E` | Exit River |

---

## Input Configuration

### Touchpad
- Device: ELAN050A (trackpad)
- Features: Tap-to-click, tap drag, pointer acceleration 0.3

### Keyboard
- Layouts: US / Arabic (Alt+Shift to toggle)
- Repeat rate: 50ms delay, 300ms repeat

---

## Float Rules

These applications float by default:
- Pinentry windows
- nm-connection-editor
- pavucontrol
- GParted
- Various dialogs (Open File, Preferences, Pictures, etc.)
- Picture-in-Picture windows

---

## Startup Programs

1. `swaybg -i ~/.config/river/bg.jpg` - Wallpaper
2. polkit-gnome-authentication-agent-1 - Authentication agent
3. mako - Notification daemon
4. waybar - Status bar

---

## Scripts

| Script | Purpose | Dependencies |
|--------|---------|--------------|
| `scripts/volume` | Volume control | pulsemixer |
| `scripts/brightness` | Backlight control | light |
| `scripts/lock` | Lock screen | swaylock |
| `scripts/clipboard` | Clipboard history | cliphist, wl-clipboard |
| `scripts/notifications` | Launch mako | mako |
| `scripts/statusbar` | Launch waybar | waybar |
| `scripts/alacritty` | Launch terminal variants | alacritty |
| `scripts/wofi_menu` | Launch wofi | wofi |

---

## Theme: Gruvbox Dark

Consistent Gruvbox dark theme across all components:

| Element | Color |
|---------|-------|
| Background | `#282828` |
| Foreground | `#ebdbb2` |
| Focused border | `#ebdbb2` |
| Unfocused border | `#504945` |
| Accent | `#fabd2f` |

---

## Installation

### Fresh Void Linux (One Command)
```bash
curl -sSL https://raw.githubusercontent.com/mugdad1/riverwm/main/bootstrap.sh | sh
```
This will:
1. Update system packages
2. Install prerequisites (git, newt, dialog)
3. Launch Void TUI for essentials
4. Clone and setup riverwm

### Quick Install (Existing System)
```bash
./setup/install.sh
```

### Manual Setup
1. Copy config files to `~/.config/river/`
2. Run `river` to start

### Package Dependencies (XBPS)
- river, wlroots
- alacritty
- waybar, mako, wofi
- pulsemixer, playerctl
- grim, slurp (screenshots)
- yazi, fzf, neovim
- fish, swaybg, light
- polkit-gnome, seatd, elogind

### Services (Void Linux)
- seatd, elogind (session management)
- tailscaled, ufw (networking)
- rtkit, polkitd (permissions)
- smartd (disk monitoring)

---

## Custom Builds

### Intel VPL GPU Runtime
Built from source at `/opt/vpl-gpu-rt` for hardware video acceleration.

### Layout Generators
- `rivertile` - Default split layout
- `wideriver` - Toggle layout with monocle
- `rivercarro` - Simplified variant

---

## Notes

- **Waybar modules:** Tags (1-7), Clock, Battery, Tray
- **Wofi:** 600x340px drun mode with GTK dark mode
- **Alacritty:** Borderless with blur, opacity 0.9
- **Mako:** Top-right anchor, urgency-aware timeouts
