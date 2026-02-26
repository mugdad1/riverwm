#!/bin/bash
# lib/utils.sh - Utility functions for logging and error handling

# Structured logging with timestamps
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $*" >&2
}

log_warn() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $*" >&2
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" >&2
    exit 1
}

# Check if command exists
cmd_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root (should not be)
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
    fi
}

# Cleanup on exit
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Script failed with exit code $exit_code"
    fi
}

trap cleanup EXIT

# Ensure directory exists
ensure_dir() {
    local dir="$1"
    if ! mkdir -p "$dir"; then
        log_error "Failed to create directory: $dir"
    fi
}

# Copy with error handling
safe_copy() {
    local src="$1"
    local dst="$2"
    if ! cp -rv "$src" "$dst"; then
        log_error "Failed to copy $src to $dst"
    fi
}

