#!/usr/bin/env bash
# env.sh - Environment variable and path utilities
# Reusable across any shell script project (macOS and Linux compatible)

# Prevent double loading
[[ -n "${SYSTEM_ENV_LOADED:-}" ]] && return 0
readonly SYSTEM_ENV_LOADED=1

# Check if environment variable is set and non-empty
# Args: variable_name
# Returns: 0 if set and non-empty, 1 otherwise
# Example: if env_is_set "HOME"; then echo "HOME is set"; fi
env_is_set() {
    local var="${1}"
    [[ -n "${!var:-}" ]]
}

# Get environment variable with default fallback
# Args: variable_name, default_value
# Returns: value or default
# Example: editor=$(env_get "EDITOR" "vim")
env_get() {
    local var="${1}"
    local default="${2:-}"
    echo "${!var:-$default}"
}

# Set environment variable if not already set
# Args: variable_name, value
# Example: env_set_default "EDITOR" "vim"
env_set_default() {
    local var="${1}"
    local value="${2}"
    if [[ -z "${!var:-}" ]]; then
        export "$var=$value"
    fi
}

# Check if running in CI environment
# Returns: 0 if CI, 1 otherwise
# Example: if env_is_ci; then echo "Running in CI"; fi
env_is_ci() {
    [[ -n "${CI:-}" ]] || \
    [[ -n "${GITHUB_ACTIONS:-}" ]] || \
    [[ -n "${GITLAB_CI:-}" ]] || \
    [[ -n "${CIRCLECI:-}" ]] || \
    [[ -n "${TRAVIS:-}" ]] || \
    [[ -n "${JENKINS_HOME:-}" ]]
}

# Check if running in Docker container
# Returns: 0 if Docker, 1 otherwise
# Example: if env_is_docker; then echo "Running in Docker"; fi
env_is_docker() {
    [[ -f /.dockerenv ]] || \
    grep -q docker /proc/1/cgroup 2>/dev/null
}

# Check if path exists in PATH variable
# Args: directory_path
# Returns: 0 if in PATH, 1 otherwise
# Example: if env_path_contains "/usr/local/bin"; then echo "In PATH"; fi
env_path_contains() {
    local dir="${1}"
    [[ ":$PATH:" == *":$dir:"* ]]
}

# Add directory to PATH if not already present
# Args: directory_path, position (prepend/append, default: prepend)
# Example: env_path_add "/usr/local/bin"
env_path_add() {
    local dir="${1}"
    local position="${2:-prepend}"

    # Check if directory exists
    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    # Check if already in PATH
    if env_path_contains "$dir"; then
        return 0
    fi

    # Add to PATH
    if [[ "$position" == "append" ]]; then
        export PATH="$PATH:$dir"
    else
        export PATH="$dir:$PATH"
    fi
}

# Remove directory from PATH
# Args: directory_path
# Example: env_path_remove "/usr/local/bin"
env_path_remove() {
    local dir="${1}"
    local new_path=""
    local IFS=":"

    for path_dir in $PATH; do
        if [[ "$path_dir" != "$dir" ]]; then
            if [[ -z "$new_path" ]]; then
                new_path="$path_dir"
            else
                new_path="$new_path:$path_dir"
            fi
        fi
    done

    export PATH="$new_path"
}

# Get shell name
# Returns: bash, zsh, fish, etc.
# Example: shell=$(env_shell)
env_shell() {
    if [[ -n "${BASH_VERSION:-}" ]]; then
        echo "bash"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        echo "zsh"
    elif [[ -n "${FISH_VERSION:-}" ]]; then
        echo "fish"
    else
        basename "${SHELL:-sh}"
    fi
}

# Check if running specific shell
# Args: shell_name (bash, zsh, fish)
# Returns: 0 if match, 1 otherwise
# Example: if env_is_shell "zsh"; then echo "Using Zsh"; fi
env_is_shell() {
    local shell="${1}"
    [[ "$(env_shell)" == "$shell" ]]
}

# Get user's home directory (more reliable than $HOME)
# Returns: home directory path
# Example: home=$(env_home)
env_home() {
    if [[ -n "${HOME:-}" ]]; then
        echo "$HOME"
    elif command -v getent >/dev/null 2>&1; then
        getent passwd "$USER" | cut -d: -f6
    else
        echo ~
    fi
}

# Get current username
# Returns: username
# Example: user=$(env_user)
env_user() {
    if [[ -n "${USER:-}" ]]; then
        echo "$USER"
    elif [[ -n "${USERNAME:-}" ]]; then
        echo "$USERNAME"
    else
        whoami 2>/dev/null || echo "unknown"
    fi
}

# Get hostname
# Returns: hostname
# Example: host=$(env_hostname)
env_hostname() {
    if [[ -n "${HOSTNAME:-}" ]]; then
        echo "$HOSTNAME"
    else
        hostname 2>/dev/null || echo "unknown"
    fi
}

# Check if running as root
# Returns: 0 if root, 1 otherwise
# Example: if env_is_root; then echo "Running as root"; fi
env_is_root() {
    [[ $EUID -eq 0 ]]
}

# Get number of CPU cores
# Returns: number of cores
# Example: cores=$(env_cpu_cores)
env_cpu_cores() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        sysctl -n hw.ncpu 2>/dev/null || echo "1"
    else
        nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "1"
    fi
}

# Get total RAM in MB
# Returns: RAM in megabytes
# Example: ram=$(env_ram_mb)
env_ram_mb() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        local bytes
        bytes=$(sysctl -n hw.memsize 2>/dev/null || echo "0")
        echo $((bytes / 1024 / 1024))
    else
        local kb
        kb=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}' || echo "0")
        echo $((kb / 1024))
    fi
}

# Export system information for debugging
# Example: env_debug_info
env_debug_info() {
    echo "Shell: $(env_shell)"
    echo "User: $(env_user)"
    echo "Home: $(env_home)"
    echo "Hostname: $(env_hostname)"
    echo "CPU Cores: $(env_cpu_cores)"
    echo "RAM (MB): $(env_ram_mb)"
    echo "CI: $(env_is_ci && echo "yes" || echo "no")"
    echo "Docker: $(env_is_docker && echo "yes" || echo "no")"
    echo "Root: $(env_is_root && echo "yes" || echo "no")"
}
