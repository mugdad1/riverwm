#!/bin/sh
#
# River WM Bootstrap - One-command setup from fresh Void Linux
# Requires: curl (comes with Void), git, newt, dialog (install via squidnose TUI)
# Usage: curl -sSL https://raw.githubusercontent.com/YOURUSER/riverwm/main/bootstrap.sh | sh
#

set -e

REPO_URL="https://github.com/mugdad1/riverwm.git"
SQUIDNOSE_URL="https://github.com/squidnose/Voidlinux-Post-Install-TUI.git"
INSTALL_DIR="$HOME/riverwm"
SQUIDNOSE_DIR="$HOME/Voidlinux-Post-Install-TUI"

info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

info "=== River WM Bootstrap ==="

# Step 1: System update
info "Updating package database..."
sudo xbps-install -Syu || error "Failed to update packages"

# Step 2: Clone squidnose TUI
if [ -d "$SQUIDNOSE_DIR" ]; then
    warn "squidnose already exists, skipping"
else
    info "Cloning squidnose TUI..."
    git clone "$SQUIDNOSE_URL" "$SQUIDNOSE_DIR" || error "Failed to clone squidnose"
fi

info "Starting Void TUI (install git, newt, dialog first if needed)..."
chmod +x "$SQUIDNOSE_DIR/VOID-TUI.sh"
"$SQUIDNOSE_DIR/VOID-TUI.sh"

# Step 3: Clone riverwm
if [ -d "$INSTALL_DIR" ]; then
    warn "riverwm already exists, updating..."
    cd "$INSTALL_DIR" && git pull
else
    info "Cloning riverwm..."
    git clone "$REPO_URL" "$INSTALL_DIR" || error "Failed to clone riverwm"
fi

# Step 4: Run setup
info "Running River WM setup..."
cd "$INSTALL_DIR"
chmod +x setup/install.sh
./setup/install.sh

info "=== Done! Log out and back in, then run 'river' ==="
