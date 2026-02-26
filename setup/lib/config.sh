#!/bin/bash
# lib/config.sh - Centralized configuration

# User and home directory
readonly USER_HOME="${HOME:-/home/$(whoami)}"

# Directory paths
readonly RIVERWM_DIR="${RIVERWM_DIR:-$USER_HOME/riverwm}"
readonly CONFIG_DIR="${XDG_CONFIG_HOME:-$USER_HOME/.config}"
readonly RIVER_CONFIG_DIR="$CONFIG_DIR/river"
readonly FISH_CONFIG_DIR="$CONFIG_DIR/fish"
readonly NVIM_CONFIG_DIR="$CONFIG_DIR/nvim"
readonly SCREENSHOTS_DIR="$USER_HOME/Pictures/screenshots"

# Intel VPL paths
readonly VPL_SOURCE="/opt/vpl-gpu-rt"
readonly VPL_BUILD_DIR="$VPL_SOURCE/build/__bin/release"

# Package list (easy to maintain)
declare -a PACKAGES=(
    "base-devel" "openjdk25" "river" "chafa" "wlroots"
    "alacritty" "Waybar" "wofi" "mako" "grim" "slurp"
    "dmidecode" "trash-cli" "swaybg" "fish-shell" "light"
    "yazi" "viewnior" "ImageMagick" "polkit-gnome"
    "xorg-server-xwayland" "xdg-desktop-portal-wlr" "pulsemixer"
    "elogind" "mesa-dri" "newt" "dialog" "fuse-sshfs"
    "tailscale" "mesa-vulkan-intel" "seatd" "dunst"
    "xdg-user-dirs-gtk" "nerd-fonts" "neovim" "ripgrep"
    "fzf" "psmisc" "nodejs" "tree-sitter" "python3-virtualenv"
    "luarocks" "go" "shellcheck" "pulseaudio" "wl-clipboard"
    "cliphist" "swaylock" "swayidle" "wlsunset"
    "obs" "kdenlive" "cmake" "pkg-config" "gcc" "libvpl-devel"
    "intel-media-driver" "libva-devel" "libdrm-devel"
)

# Services to enable
declare -a SERVICES=("seatd" "tailscaled" "ufw" "rtkit" "polkitd" "elogind" "smartd")

