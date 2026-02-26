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
    VPL_SOURCE="/opt/vpl-gpu-rt"
    # Matches the 'release' folder created by CMake
    VPL_BUILD_DIR="$VPL_SOURCE/build/__bin/release"  # Changed 'Release' to 'release'
}

# Ensure we have the necessary directories
create_directories() {
    echo "[*] Creating necessary directories..."
    mkdir -p "$RIVER_CONFIG_DIR" "$FISH_CONFIG_DIR" "$USER_HOME/Pictures/screenshots" || die "Directory creation failed"
}

# Install packages
install_packages() {
    echo "[*] Installing system packages..."
    sudo xbps-install -Syu openjdk25 river chafa wlroots alacritty Waybar wofi mako grim \
        slurp dmidecode trash-cli swaybg fish-shell light yazi viewnior ImageMagick polkit-gnome \
        xorg-server-xwayland xdg-desktop-portal-wlr pulsemixer elogind \
        mesa-dri newt dialog fuse-sshfs tailscale mesa-vulkan-intel seatd dunst xdg-user-dirs-gtk nerd-fonts \
        neovim ripgrep fzf psmisc nodejs tree-sitter python3-virtualenv luarocks go shellcheck pulseaudio \
        wl-clipboard cliphist swaylock swayidle wlsunset \
        obs kdenlive cmake pkg-config gcc libvpl-devel intel-media-driver libva-devel libdrm-devel  \
        || die "Package installation failed"
}

# Build and Setup Intel VPL (Handles re-runs and Case Sensitivity)
setup_intel_vpl() {
    echo "[*] Setting up Intel VPL GPU Runtime..."

    if [ -d "$VPL_SOURCE" ]; then
        echo "[*] Directory exists. Updating source..."
        cd "$VPL_SOURCE" || die "Failed to enter VPL source directory"
        sudo git pull || echo "[!] Git pull failed, proceeding with existing code."
    else
        sudo git clone --depth 1 https://github.com/intel/vpl-gpu-rt "$VPL_SOURCE" || die "VPL clone failed"
    fi

    # Create build directory with root permissions
    BUILD_DIR="$VPL_SOURCE/build"
    sudo mkdir -p "$BUILD_DIR" || die "Failed to create build directory"
    cd "$BUILD_DIR" || die "Failed to enter build directory"

    # Check for dependencies before configuring
    if ! command -v cmake >/dev/null; then
        die "CMake is not installed. Please install CMake to proceed."
    fi

    # Run CMake to configure the build
    sudo cmake .. || die "CMake configuration failed"

    # Build and Install
    if sudo make -j$(nproc); then
        echo "[*] Build successful, proceeding to install..."
        sudo make install || die "Installation failed"
    else
        die "Build failed"
    fi

    # Update VPL symlinks
    update_vpl_symlinks
}

# Update VPL symlinks without hardcoding filenames
update_vpl_symlinks() {
    echo "[*] Updating VPL symlinks..."
    if [ -d "$VPL_BUILD_DIR" ]; then
        cd "$VPL_BUILD_DIR" || die "Failed to enter build directory"

        # Find the latest version of the library files
        LIBRARY_VERSION=$(ls libmfx-gen.so.* 2>/dev/null | sort -V | tail -n 1)
        if [ -n "$LIBRARY_VERSION" ]; then
            BASE_NAME=$(basename "$LIBRARY_VERSION")
            # Remove version suffix to create symlinks
            BASE_NO_VERSION="${BASE_NAME%.*}"

            # Create symlinks to the latest version of the library
            for version in 1.2 1 ""; do
                sudo ln -sf "$BASE_NAME" "${BASE_NO_VERSION}.${version}" || die "Failed to create symlink for ${BASE_NO_VERSION}.${version}"
            done
        else
            die "No library files found in $VPL_BUILD_DIR!"
        fi
    else
        die "Build directory $VPL_BUILD_DIR not found!"
    fi

    echo "[*] Intel VPL setup completed successfully."
}

# Update Fish config using sed (Handles re-runs)
update_fish_env() {
    FISH_SOURCE_FILE="$RIVERWM_DIR/fish/config.fish"

    if [ -f "$FISH_SOURCE_FILE" ]; then
        echo "[*] Injecting VPL paths into $FISH_SOURCE_FILE..."
        # Deletes any existing lines containing VPL or ONEVPL to prevent duplicates
        sed -i '/VPL/d' "$FISH_SOURCE_FILE"
        sed -i '/ONEVPL/d' "$FISH_SOURCE_FILE"

        {
            echo ""
            echo "# Intel VPL Environment (QSV)"
            echo "set -gx ONEVPL_PRIORITY_PATH $VPL_BUILD_DIR"
            echo "set -gx LD_LIBRARY_PATH \$ONEVPL_PRIORITY_PATH \$LD_LIBRARY_PATH"
        } >> "$FISH_SOURCE_FILE"
    else
        echo "[!] Warning: Source fish config not found at $FISH_SOURCE_FILE"
    fi
}

# Copy River configuration
copy_river_config() {
    if [ ! -d "$RIVERWM_DIR" ]; then
        die "River configuration source directory not found: $RIVERWM_DIR"
    fi
    find "$RIVERWM_DIR" -mindepth 1 -maxdepth 1 ! -name 'fish' ! -name '.git' -exec cp -rv {} "$RIVER_CONFIG_DIR/" \;
}

# Copy Fish shell configuration
copy_fish_config() {
    if [ -d "$RIVERWM_DIR/fish" ]; then
        mkdir -p "$FISH_CONFIG_DIR"
        cp -rv "$RIVERWM_DIR/fish"/* "$FISH_CONFIG_DIR/" || die "Failed to copy Fish configuration"
    fi
}

# Set up Neovim configuration
setup_neovim_config() {
    if [ ! -d "$NVIM_CONFIG_DIR" ] || [ -z "$(ls -A "$NVIM_CONFIG_DIR")" ]; then
        git clone --depth 1 https://github.com/AstroNvim/template "$NVIM_CONFIG_DIR" ||
            die "Neovim configuration clone failed"
        rm -rf "$NVIM_CONFIG_DIR/.git"
    else
        echo "[!] Neovim configuration already exists; skipping clone."
    fi
}

# Make River init script executable
make_init_executable() {
    RIVER_INIT="$RIVER_CONFIG_DIR/init"
    if [ -f "$RIVER_INIT" ]; then
        chmod +x "$RIVER_INIT"
    fi
}

# Enable services
enable_services() {
    sudo ln -sf /etc/sv/{seatd,tailscaled,ufw,rtkit,polkitd,elogind,smartd} /var/service/ ||
        die "Failed to enable services"
}

# Set fish as the default shell
set_fish_shell() {
    if [ "$EUID" -eq 0 ]; then return; fi
    FISH_PATH=$(command -v fish) || die "Fish shell not found"
    if ! grep -q "^${FISH_PATH}$" /etc/shells; then
        echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi
    if [ "$SHELL" != "$FISH_PATH" ]; then
        chsh -s "$FISH_PATH" || die "Failed to change shell"
    fi
}

# Fix permissions
fix_permissions() {
    chown -R "$(whoami):$(whoami)" "$CONFIG_DIR" "$USER_HOME/Pictures" 2>/dev/null || true
}

# Main script execution
main() {
    detect_user_home
    define_directories
    create_directories
    install_packages

    # Intel QSV Logic
    setup_intel_vpl
    update_fish_env

    copy_river_config
    copy_fish_config
    setup_neovim_config
    make_init_executable
    enable_services
    set_fish_shell
    fix_permissions

    echo "[*] Installation finished successfully!"
    echo "[*] IMPORTANT: You must log out or reboot for group and shell changes to apply."
}

main
