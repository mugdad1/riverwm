#!/bin/bash
# lib/vpl.sh - Intel VPL GPU Runtime setup

#######################################
# Setup Intel VPL GPU Runtime
# Globals:
#   VPL_SOURCE
#   VPL_BUILD_DIR
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
setup_intel_vpl() {
    log_info "Setting up Intel VPL GPU Runtime..."
    
    # Clone or update repository
    if [[ -d "$VPL_SOURCE" ]]; then
        log_info "VPL directory exists. Updating source..."
        cd "$VPL_SOURCE" || log_error "Failed to enter VPL source directory"
        if ! sudo git pull; then
            log_warn "Git pull failed, proceeding with existing code"
        fi
    else
        if ! sudo git clone --depth 1 https://github.com/intel/vpl-gpu-rt "$VPL_SOURCE"; then
            log_error "VPL clone failed"
        fi
    fi
    
    # Build with CMake
    vpl_build
    
    # Setup symlinks
    vpl_setup_symlinks
    
    log_info "Intel VPL setup completed"
}

#######################################
# Build Intel VPL
# Globals:
#   VPL_SOURCE
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
vpl_build() {
    local build_dir="$VPL_SOURCE/build"
    
    log_info "Building Intel VPL..."
    
    # Check dependencies
    if ! cmd_exists cmake; then
        log_error "CMake is not installed"
    fi
    
    # Create and enter build directory
    sudo mkdir -p "$build_dir" || log_error "Failed to create build directory"
    cd "$build_dir" || log_error "Failed to enter build directory"
    
    # Configure
    if ! sudo cmake ..; then
        log_error "CMake configuration failed"
    fi
    
    # Build
    if ! sudo make -j"$(nproc)"; then
        log_error "Build failed"
    fi
    
    # Install
    if ! sudo make install; then
        log_error "Installation failed"
    fi
    
    log_info "VPL build completed"
}

#######################################
# Setup VPL library symlinks
# Globals:
#   VPL_BUILD_DIR
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
vpl_setup_symlinks() {
    log_info "Updating VPL symlinks..."
    
    if [[ ! -d "$VPL_BUILD_DIR" ]]; then
        log_error "Build directory not found: $VPL_BUILD_DIR"
    fi
    
    cd "$VPL_BUILD_DIR" || log_error "Failed to enter build directory"
    
    # Find the latest library version
    local lib_file
    lib_file=$(find . -name "libmfx-gen.so.*" -type f 2>/dev/null | sort -V | tail -1)
    
    if [[ -z "$lib_file" ]]; then
        log_error "No libmfx-gen.so found in $VPL_BUILD_DIR"
    fi
    
    local base_name="${lib_file##*/}"
    local base_no_version="${base_name%.*}"
    
    # Create symlinks
    for version in 1.2 1 ""; do
        local link_name="${base_no_version}.${version}"
        if ! sudo ln -sf "$base_name" "$link_name"; then
            log_warn "Failed to create symlink for $link_name"
        fi
    done
    
    log_info "VPL symlinks updated"
}

