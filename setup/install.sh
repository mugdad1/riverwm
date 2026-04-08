#!/bin/bash
#
# River WM Setup Script - Modular Installation
# Refactored for maintainability
#

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all libraries
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/config.sh"
source "$SCRIPT_DIR/lib/packages.sh"
source "$SCRIPT_DIR/lib/vpl.sh"
source "$SCRIPT_DIR/lib/config_apps.sh"
source "$SCRIPT_DIR/lib/services.sh"

#######################################
# Pre-flight checks
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
preflight_checks() {
    log_info "Running pre-flight checks..."
    
    check_not_root
    
    # Check and install required commands
    local required_cmds=("sudo" "whoami")
    local install_cmds=()
    for cmd in "${required_cmds[@]}"; do
        if ! cmd_exists "$cmd"; then
            install_cmds+=("$cmd")
        fi
    done
    
    # Auto-install git if missing
    if ! cmd_exists git; then
        log_info "Installing git..."
        sudo xbps-install -S git || log_error "Failed to install git"
    fi
    
    if [ ${#install_cmds[@]} -gt 0 ]; then
        log_error "Missing required commands: ${install_cmds[*]}"
    fi
    
    log_info "Pre-flight checks passed"
}

#######################################
# Main installation routine
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
main() {
    log_info "=== River WM Setup Started ==="
    
    # Run checks
    preflight_checks
    
    # Create directories
    create_directories
    
    # Install packages
    install_packages
    
    # Setup Intel VPL
    setup_intel_vpl
    
    # Configure applications
    link_river_config
    link_fish_config
    update_fish_env
    setup_neovim_config
    make_init_executable
    
    # Enable services
    enable_services
    
    # Set Fish shell
    set_fish_shell
    
    # Fix permissions
    fix_permissions
    
    log_info "=== Installation completed successfully! ==="
    log_warn "IMPORTANT: You must log out or reboot for group and shell changes to apply."
}

# Run main function
main "$@"

