#!/bin/sh
set -e

# Improved error handling function
die() {
	echo "[ERROR] $*" >&2
	exit 1
}

# Detect user home directory
USER_HOME="${HOME:-/home/$(whoami)}"

# Define key directories with more robust path handling
RIVERWM_DIR="${RIVERWM_DIR:-$USER_HOME/riverwm}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$USER_HOME/.config}"
RIVER_CONFIG_DIR="$CONFIG_DIR/river"

# Ensure we have the necessary directories
mkdir -p "$RIVER_CONFIG_DIR" "$USER_HOME/Pictures/screenshots"

# Comprehensive package installation
echo "[*] Installing packages (may prompt for password)..."
sudo xbps-install -Syu river chafa wlroots alacritty Waybar wofi mako grim \
	slurp fish-shell light yazi viewnior ImageMagick polkit-gnome \
	xorg-server-xwayland xdg-desktop-portal-wlr pulsemixer elogind \
	mesa-dri fuse-sshfs tailscale mesa-vulkan-intel seatd dunst xdg-user-dirs-gtk nerd-fonts \
	neovim ripgrep fzf nodejs tree-sitter python3-virtualenv luarocks go shellcheck pulseaudio wl-clipboard cliphist swaylock swayidle wlsunset ||
	die "Package installation failed"

# Check and remove problematic literal-brace directory
BAD_DIR="$CONFIG_DIR/{river,fish}"
if [ -e "$BAD_DIR" ]; then
	echo "[*] Removing literal directory: $BAD_DIR"
	rm -rf "$BAD_DIR"
fi

# Robust River configuration copying
echo "[*] Copying River configuration..."
if [ ! -d "$RIVERWM_DIR" ]; then
	die "River configuration source directory not found: $RIVERWM_DIR"
fi

# Detailed copying with verbose output and error checking
if [ -d "$RIVERWM_DIR" ] && [ "$(ls -A "$RIVERWM_DIR")" ]; then
	# Ensure destination is empty or create it
	mkdir -p "$RIVER_CONFIG_DIR"

	# Copy with verbose output and error handling
	cp -rv "$RIVERWM_DIR"/* "$RIVER_CONFIG_DIR/" || {
		echo "[!] Warning: Some files might not have been copied"
	}
else
	die "River configuration source is empty or not a directory"
fi

# Fish shell configuration copying
FISH_CONFIG_DIR="$CONFIG_DIR/fish"
mkdir -p "$FISH_CONFIG_DIR"
if [ -d "$RIVERWM_DIR/fish" ] && [ "$(ls -A "$RIVERWM_DIR/fish")" ]; then
	cp -rv "$RIVERWM_DIR/fish"/* "$FISH_CONFIG_DIR/" || {
		echo "[!] Warning: Fish configuration copy incomplete"
	}
fi

# Neovim configuration
echo "[*] Setting up Neovim configuration..."
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim ||
	die "Neovim configuration clone failed"
rm -rf ~/.config/nvim/.git

# Make River init script executable if it exists
RIVER_INIT="$RIVER_CONFIG_DIR/init"
if [ -f "$RIVER_INIT" ]; then
	chmod +x "$RIVER_INIT"
	echo "[*] Made $RIVER_INIT executable."
else
	echo "[!] Warning: $RIVER_INIT not found; skipping chmod."
fi

# Enable Tailscale service
sudo ln -sf /etc/sv/tailscaled /var/service/ ||
	echo "[!] Failed to enable Tailscale service"

# Final verification
echo "[*] Configuration complete. Verifying directories:"
ls -la "$CONFIG_DIR/river"

echo "[*] Installation finished successfully!"
