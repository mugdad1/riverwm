#!/bin/sh
set -e

USER_HOME="${HOME:-/home/$(whoami)}"
RIVERWM_DIR="$USER_HOME/riverwm"
CONFIG_DIR="$USER_HOME/.config"

echo "[*] Installing packages (may prompt for password)..."
sudo xbps-install -Syu river chafa wlroots alacritty Waybar wofi mako grim \
	slurp fish-shell light yazi viewnior ImageMagick polkit-gnome \
	xorg-server-xwayland xdg-desktop-portal-wlr pulsemixer elogind \
	mesa-dri tailscale mesa-vulkan-intel seatd dunst xdg-user-dirs-gtk nerd-fonts \
	neovim ripgrep fzf nodejs tree-sitter python3-virtualenv luarocks go shellcheck pulseaudio wl-clipboard cliphist swaylock swayidle wlsunset

echo "[*] Fixing mistaken literal-brace directory if present..."
BAD_DIR="$CONFIG_DIR/{river,micro,fish}"
if [ -e "$BAD_DIR" ]; then
	echo "Removing literal directory: $BAD_DIR"
	rm -rf "$BAD_DIR"
fi

echo "[*] Creating config directories..."
# Use explicit separate names to be portable across shells
mkdir -p "$CONFIG_DIR/river" "$CONFIG_DIR/fish" "$HOME/Pictures/screenshots"

git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
rm -rf ~/.config/nvim/.git
echo "[*] Copying configuration files..."
# Use -r and check source existence before copying

if [ -d "$RIVERWM_DIR/fish" ]; then
	cp -r "$RIVERWM_DIR/fish/"* "$CONFIG_DIR/fish/" 2>/dev/null || true
fi

# Copy river config directory contents into ~/.config/river
if [ -d "$RIVERWM_DIR" ]; then
	cp -r "$RIVERWM_DIR/"* "$CONFIG_DIR/river/" 2>/dev/null || true
fi
sudo ln -s /etc/sv/tailscaled /var/service/
# Make sure init exists and is executable
if [ -f "$CONFIG_DIR/river/init" ]; then
	chmod +x "$CONFIG_DIR/river/init"
	echo "[*] Made $CONFIG_DIR/river/init executable."
else
	echo "[!] Warning: $CONFIG_DIR/river/init not found; skipping chmod."
fi

echo "[*] Done. Verify with: ls -la \"$CONFIG_DIR\""
