#!/bin/bash
# lib/config_apps.sh - Configure River, Fish, Neovim, Alacritty, Mako

#######################################
# Create necessary directories
# Globals:
#   RIVER_CONFIG_DIR
#   FISH_CONFIG_DIR
#   ALACRITTY_CONFIG_DIR
#   SCREENSHOTS_DIR
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
create_directories() {
    log_info "Creating necessary directories..."
    
    ensure_dir "$RIVER_CONFIG_DIR"
    ensure_dir "$FISH_CONFIG_DIR"
    ensure_dir "$ALACRITTY_CONFIG_DIR"
    ensure_dir "$SCREENSHOTS_DIR"
    ensure_dir "$RIVER_CONFIG_DIR/mako/icons"
    
    log_info "Directories created"
}

#######################################
# Copy River configuration
# Globals:
#   RIVERWM_DIR
#   RIVER_CONFIG_DIR
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
link_river_config() {
    log_info "Copying River configuration..."
    
    if [[ ! -d "$RIVERWM_DIR" ]]; then
        log_error "River config source not found: $RIVERWM_DIR"
    fi
    
    if [[ -L "$RIVER_CONFIG_DIR" ]] || [[ -d "$RIVER_CONFIG_DIR" ]]; then
        log_warn "Removing existing River config at $RIVER_CONFIG_DIR"
        rm -rf "$RIVER_CONFIG_DIR"
    fi
    cp -r "$RIVERWM_DIR" "$RIVER_CONFIG_DIR"
    
    log_info "River configuration copied"
}

#######################################
# Link Mako notification configuration
# Globals:
#   RIVERWM_DIR
#   RIVER_CONFIG_DIR
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
link_mako_config() {
    log_info "Copying Mako configuration..."
    
    if [[ ! -d "$RIVERWM_DIR/mako" ]]; then
        log_warn "Mako config source not found: $RIVERWM_DIR/mako"
        return 0
    fi
    
    ensure_dir "$RIVER_CONFIG_DIR/mako"
    ensure_dir "$RIVER_CONFIG_DIR/mako/icons"
    
    cp "$RIVERWM_DIR/mako/config" "$RIVER_CONFIG_DIR/mako/config"
    cp -r "$RIVERWM_DIR/mako/icons/"* "$RIVER_CONFIG_DIR/mako/icons/"
    
    log_info "Mako configuration copied"
}

#######################################
# Symlink Fish shell configuration
# Globals:
#   RIVERWM_DIR
#   FISH_CONFIG_DIR
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
link_fish_config() {
    log_info "Symlinking Fish configuration..."
    
    if [[ ! -d "$RIVERWM_DIR/fish" ]]; then
        log_warn "Fish config source not found: $RIVERWM_DIR/fish"
        return 0
    fi
    
    if [[ -L "$FISH_CONFIG_DIR" ]] || [[ -d "$FISH_CONFIG_DIR" ]]; then
        log_warn "Removing existing Fish config at $FISH_CONFIG_DIR"
        rm -rf "$FISH_CONFIG_DIR"
    fi
    mkdir -p "$(dirname "$FISH_CONFIG_DIR")"
    cp -r "$RIVERWM_DIR/fish" "$FISH_CONFIG_DIR"
    
    log_info "Fish configuration symlinked"
}

#######################################
# Symlink Alacritty configuration
# Globals:
#   RIVERWM_DIR
#   ALACRITTY_CONFIG_DIR
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
link_alacritty_config() {
    log_info "Symlinking Alacritty configuration..."
    
    if [[ ! -d "$RIVERWM_DIR/alacritty" ]]; then
        log_warn "Alacritty config source not found: $RIVERWM_DIR/alacritty"
        return 0
    fi
    
    if [[ -L "$ALACRITTY_CONFIG_DIR" ]] || [[ -d "$ALACRITTY_CONFIG_DIR" ]]; then
        log_warn "Removing existing Alacritty config at $ALACRITTY_CONFIG_DIR"
        rm -rf "$ALACRITTY_CONFIG_DIR"
    fi
    mkdir -p "$(dirname "$ALACRITTY_CONFIG_DIR")"
    cp -r "$RIVERWM_DIR/alacritty" "$ALACRITTY_CONFIG_DIR"
    
    log_info "Alacritty configuration symlinked"
}

#######################################
# Inject Intel VPL environment into Fish config
# Globals:
#   FISH_CONFIG_DIR
#   VPL_BUILD_DIR
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
update_fish_env() {
    local fish_config="$FISH_CONFIG_DIR/config.fish"
    
    log_info "Injecting VPL paths into Fish config..."
    
    if [[ ! -f "$fish_config" ]]; then
        log_warn "Fish config not found: $fish_config"
        return 0
    fi
    
    # Remove existing VPL lines to prevent duplicates
    sed -i '/VPL/d; /ONEVPL/d' "$fish_config"
    
    # Append VPL environment
    {
        echo ""
        echo "# Intel VPL Environment (QSV)"
        echo "set -gx ONEVPL_PRIORITY_PATH $VPL_BUILD_DIR"
        echo "set -gx LD_LIBRARY_PATH \$ONEVPL_PRIORITY_PATH \$LD_LIBRARY_PATH"
    } >> "$fish_config"
    
    log_info "VPL paths injected into Fish config"
}

#######################################
# Setup Neovim configuration
# Globals:
#   NVIM_CONFIG_DIR
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
setup_neovim_config() {
    log_info "Setting up Neovim configuration..."
    
    if [[ -d "$NVIM_CONFIG_DIR" ]] && [[ -n "$(ls -A "$NVIM_CONFIG_DIR" 2>/dev/null)" ]]; then
        log_warn "Neovim config already exists, skipping"
        return 0
    fi
    
    ensure_dir "$NVIM_CONFIG_DIR"
    
    if ! git clone --depth 1 https://github.com/AstroNvim/template "$NVIM_CONFIG_DIR"; then
        log_error "Neovim template clone failed"
    fi
    
    rm -rf "$NVIM_CONFIG_DIR/.git"
    log_info "Neovim configuration installed"
}

#######################################
# Make River init script executable
# Globals:
#   RIVER_CONFIG_DIR
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
make_init_executable() {
    local init_script="$RIVER_CONFIG_DIR/init"
    
    if [[ -f "$init_script" ]]; then
        chmod +x "$init_script"
        log_info "River init script made executable"
    fi
}

#######################################
# Set Fish as default shell
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 on success, exits on failure
#######################################
set_fish_shell() {
    check_not_root
    
    log_info "Setting Fish as default shell..."
    
    local fish_path
    fish_path=$(command -v fish) || log_error "Fish shell not found"
    
    # Add to /etc/shells if not present
    if ! grep -q "^${fish_path}$" /etc/shells; then
        echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
    fi
    
    # Change shell if needed
    if [[ "$SHELL" != "$fish_path" ]]; then
        if ! chsh -s "$fish_path"; then
            log_warn "Failed to change shell (may require manual action)"
        fi
    fi
    
    log_info "Fish shell configured"
}

#######################################
# Fix file permissions
# Globals:
#   CONFIG_DIR
#   USER_HOME
# Arguments:
#   None
# Returns:
#   0 on success
#######################################
fix_permissions() {
    log_info "Fixing file permissions..."
    
    chown -R "$(whoami):$(whoami)" "$CONFIG_DIR" "$USER_HOME/Pictures" 2>/dev/null || true
    
    log_info "Permissions fixed"
}

