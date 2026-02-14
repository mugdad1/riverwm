#!/bin/bash
set -e

# Improved error handling function
die() {
	echo "[ERROR] $*" >&2
	exit 1
}

# Detect user home directory
detect_user_home() {
	USER_HOME="${HOME:-/home/$(whoami)}"
}

# Define key directories
define_directories() {
	RIVERWM_DIR="${RIVERWM_DIR:-$USER_HOME/riverwm}"
	CONFIG_DIR="${XDG_CONFIG_HOME:-$USER_HOME/.config}"
	RIVER_CONFIG_DIR="$CONFIG_DIR/river"
	FISH_CONFIG_DIR="$CONFIG_DIR/fish"
	NVIM_CONFIG_DIR="$CONFIG_DIR/nvim"
}

# Ensure we have the necessary directories
create_directories() {
	mkdir -p "$RIVER_CONFIG_DIR" "$FISH_CONFIG_DIR" "$USER_HOME/Pictures/screenshots"
}

# Install packages
install_packages() {
	sudo xbps-install -Syu river chafa wlroots alacritty Waybar wofi mako grim \
		slurp fish-shell light yazi viewnior ImageMagick polkit-gnome \
		xorg-server-xwayland xdg-desktop-portal-wlr pulsemixer elogind \
		mesa-dri fuse-sshfs tailscale mesa-vulkan-intel seatd dunst xdg-user-dirs-gtk nerd-fonts \
		neovim ripgrep fzf psmisc nodejs tree-sitter python3-virtualenv luarocks go shellcheck pulseaudio wl-clipboard cliphist swaylock swayidle wlsunset ||
		die "Package installation failed"
}

# Copy River configuration excluding the fish and .git directories
copy_river_config() {
	if [ ! -d "$RIVERWM_DIR" ]; then
		die "River configuration source directory not found: $RIVERWM_DIR"
	fi
	find "$RIVERWM_DIR" -mindepth 1 -maxdepth 1 ! -name 'fish' ! -name '.git' -exec cp -rv {} "$RIVER_CONFIG_DIR/" \;
}

# Copy Fish shell configuration
copy_fish_config() {
	if [ -d "$RIVERWM_DIR/fish" ]; then
		cp -rv "$RIVERWM_DIR/fish"/* "$FISH_CONFIG_DIR/" || die "Failed to copy Fish configuration"
	else
		echo "[!] Warning: Fish configuration directory not found: $RIVERWM_DIR/fish"
	fi
}

# Set up Neovim configuration if not already present
setup_neovim_config() {
	if [ ! -d "$NVIM_CONFIG_DIR" ] || [ -z "$(ls -A "$NVIM_CONFIG_DIR")" ]; then
		git clone --depth 1 https://github.com/AstroNvim/template "$NVIM_CONFIG_DIR" ||
			die "Neovim configuration clone failed"
		rm -rf "$NVIM_CONFIG_DIR/.git"
	else
		echo "[!] Neovim configuration already exists; skipping clone."
	fi
}

# Make River init script executable if it exists
make_init_executable() {
	RIVER_INIT="$RIVER_CONFIG_DIR/init"
	if [ -f "$RIVER_INIT" ]; then
		chmod +x "$RIVER_INIT"
	else
		echo "[!] Warning: $RIVER_INIT not found; skipping chmod."
	fi
}

# Enable Tailscale service
enable_tailscale() {
	sudo ln -sf /etc/sv/tailscaled /var/service/ ||
		die "Failed to enable Tailscale service"
}

# Main script execution
main() {
	detect_user_home
	define_directories
	create_directories
	install_packages
	copy_river_config
	copy_fish_config
	setup_neovim_config
	make_init_executable
	enable_tailscale
	echo "[*] Installation finished successfully!"
}

# Run the main function
main
