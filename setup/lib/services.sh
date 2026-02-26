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
    
    local service_links=()
    for service in "${SERVICES[@]}"; do
        service_links+=("/etc/sv/$service")
    done
    
    if ! sudo ln -sf "${service_links[@]}" /var/service/; then
        log_error "Failed to enable services"
    fi
    
    log_info "Services enabled"
}

