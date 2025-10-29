#!/usr/bin/env bash
# validation.sh - Simple validation utilities
# Reusable across any shell script project (macOS and Linux compatible)

# Prevent double loading
[[ -n "${VALIDATION_LOADED:-}" ]] && return 0
readonly VALIDATION_LOADED=1

# Validate file exists and is readable
# Args: filepath
# Returns: 0 if valid, 1 if not
validate_file_exists() {
    local file="$1"
    [[ -f "$file" && -r "$file" ]]
}

# Validate file exists and is writable
# Args: filepath
# Returns: 0 if valid, 1 if not
validate_file_writable() {
    local file="$1"
    if [[ -f "$file" ]]; then
        [[ -w "$file" ]]
    else
        # Check if parent directory is writable for new files
        local dir
        dir="$(dirname "$file")"
        [[ -d "$dir" && -w "$dir" ]]
    fi
}

# Validate directory exists and is readable
# Args: dirpath
# Returns: 0 if valid, 1 if not
validate_dir_exists() {
    local dir="$1"
    [[ -d "$dir" && -r "$dir" ]]
}

# Validate directory exists and is writable
# Args: dirpath
# Returns: 0 if valid, 1 if not
validate_dir_writable() {
    local dir="$1"
    [[ -d "$dir" && -w "$dir" ]]
}

# Validate URL format (basic check)
# Args: url
# Returns: 0 if valid format, 1 if not
validate_url() {
    local url="$1"
    # Simple URL validation - starts with http:// or https://
    [[ "$url" == http://* ]] || [[ "$url" == https://* ]]
}

# Validate email format (basic check)
# Args: email
# Returns: 0 if valid format, 1 if not
validate_email() {
    local email="$1"
    [[ "$email" =~ ^[[:alnum:]._-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}$ ]]
}

# Validate integer number
# Args: value
# Returns: 0 if valid integer, 1 if not
validate_integer() {
    local value="$1"
    [[ "$value" =~ ^-?[0-9]+$ ]]
}

# Validate float number
# Args: value
# Returns: 0 if valid float, 1 if not
validate_float() {
    local value="$1"
    [[ "$value" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]
}

# Validate positive integer
# Args: value
# Returns: 0 if valid positive integer, 1 if not
validate_positive_int() {
    local value="$1"
    [[ "$value" =~ ^[1-9][0-9]*$ ]]
}

# Validate non-negative integer (0 or positive)
# Args: value
# Returns: 0 if valid, 1 if not
validate_non_negative_int() {
    local value="$1"
    [[ "$value" =~ ^[0-9]+$ ]]
}

# Validate value is in a list of choices
# Args: value, choice1, choice2, ...
# Returns: 0 if value is in choices, 1 if not
validate_choice() {
    local value="$1"
    shift
    local choice
    for choice in "$@"; do
        [[ "$value" == "$choice" ]] && return 0
    done
    return 1
}

# Validate string is not empty
# Args: string
# Returns: 0 if not empty, 1 if empty
validate_not_empty() {
    local value="$1"
    [[ -n "$value" ]]
}

# Validate string length is within range
# Args: string, min_length, max_length
# Returns: 0 if valid length, 1 if not
validate_length() {
    local value="$1"
    local min_len="$2"
    local max_len="$3"
    local len=${#value}
    [[ $len -ge $min_len && $len -le $max_len ]]
}

# Validate command exists in PATH
# Args: command_name
# Returns: 0 if command exists, 1 if not
validate_command() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1
}

# Validate IP address format (basic IPv4)
# Args: ip_address
# Returns: 0 if valid format, 1 if not
validate_ipv4() {
    local ip="$1"
    if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        # Check each octet is 0-255
        local IFS='.'
        local -a octets
        read -ra octets <<< "$ip"
        local octet
        for octet in "${octets[@]}"; do
            [[ $octet -ge 0 && $octet -le 255 ]] || return 1
        done
        return 0
    fi
    return 1
}

# Validate port number
# Args: port
# Returns: 0 if valid port (1-65535), 1 if not
validate_port() {
    local port="$1"
    if validate_positive_int "$port"; then
        [[ $port -ge 1 && $port -le 65535 ]]
    else
        return 1
    fi
}

# Validate alphanumeric string (letters and numbers only)
# Args: string
# Returns: 0 if valid, 1 if not
validate_alphanumeric() {
    local value="$1"
    [[ "$value" =~ ^[[:alnum:]]+$ ]]
}

# Validate alphanumeric with hyphens and underscores
# Args: string
# Returns: 0 if valid, 1 if not
validate_identifier() {
    local value="$1"
    [[ "$value" =~ ^[[:alnum:]_-]+$ ]]
}

# Validate semantic version (basic semver: x.y.z)
# Args: version
# Returns: 0 if valid semver, 1 if not
validate_semver() {
    local version="$1"
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}
