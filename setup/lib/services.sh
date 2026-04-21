#!/bin/bash
# lib/services.sh - Enable system services

#######################################
# Enable system services
# Globals:
#   SERVICES (array)
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
enable_services() {
    log_info "Enabling system services..."
    
    for service in "${SERVICES[@]}"; do
        if ! sudo ln -sf "/etc/sv/$service" "/var/service/$service"; then
            log_warn "Failed to enable service: $service"
        fi
    done
    
    log_info "Services enabled"
}

