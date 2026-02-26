#!/bin/bash
# lib/packages.sh - System package installation

#######################################
# Install system packages
# Globals:
#   PACKAGES (array)
# Arguments:
#   None
# Returns:
#   0 on success, 1 on failure
#######################################
install_packages() {
    log_info "Installing system packages..."
    
    if ! sudo xbps-install -Syu "${PACKAGES[@]}"; then
        log_error "Package installation failed"
    fi
    
    log_info "Packages installed successfully"
}

