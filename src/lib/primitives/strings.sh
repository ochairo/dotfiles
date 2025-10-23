#!/usr/bin/env bash
# strings.sh - Comprehensive string manipulation utilities
# Reusable across any shell script project (macOS and Linux compatible)

# Prevent double loading
[[ -n "${STRINGS_LOADED:-}" ]] && return 0
readonly STRINGS_LOADED=1

# Trim whitespace from string
# Args: string
# Output: trimmed string
string_trim() {
    local str="$1"
    # Remove leading whitespace
    str="${str#"${str%%[![:space:]]*}"}"
    # Remove trailing whitespace
    str="${str%"${str##*[![:space:]]}"}"
    printf '%s\n' "$str"
}

# Convert string to uppercase
# Args: string
# Output: uppercase string
string_upper() {
    printf '%s\n' "${1^^}"
}

# Convert string to lowercase
# Args: string
# Output: lowercase string
string_lower() {
    printf '%s\n' "${1,,}"
}

# Check if string starts with prefix
# Args: string, prefix
# Returns: 0 if starts with prefix, 1 otherwise
string_starts_with() {
    local string="$1"
    local prefix="$2"
    [[ "$string" == "$prefix"* ]]
}

# Check if string ends with suffix
# Args: string, suffix
# Returns: 0 if ends with suffix, 1 otherwise
string_ends_with() {
    local string="$1"
    local suffix="$2"
    [[ "$string" == *"$suffix" ]]
}

# Check if string contains substring
# Args: string, substring
# Returns: 0 if contains substring, 1 otherwise
string_contains() {
    local string="$1"
    local substring="$2"
    [[ "$string" == *"$substring"* ]]
}

# Get string length
# Args: string
# Output: length
string_length() {
    printf '%d\n' "${#1}"
}

# Split string by delimiter
# Args: string, delimiter
# Output: parts, one per line
string_split() {
    local string="$1"
    local delimiter="$2"

    # Handle empty string
    [[ -n "$string" ]] || return 0

    # Use parameter expansion to split
    local IFS="$delimiter"
    local -a parts
    read -ra parts <<< "$string"
    printf '%s\n' "${parts[@]}"
}

# Replace first occurrence of pattern in string
# Args: string, pattern, replacement
# Output: string with first replacement
string_replace_first() {
    local string="$1"
    local pattern="$2"
    local replacement="$3"
    printf '%s\n' "${string/$pattern/$replacement}"
}

# Replace all occurrences of pattern in string
# Args: string, pattern, replacement
# Output: string with all replacements
string_replace_all() {
    local string="$1"
    local pattern="$2"
    local replacement="$3"
    printf '%s\n' "${string//$pattern/$replacement}"
}

# Remove prefix from string
# Args: string, prefix
# Output: string without prefix
string_remove_prefix() {
    local string="$1"
    local prefix="$2"
    printf '%s\n' "${string#"$prefix"}"
}

# Remove suffix from string
# Args: string, suffix
# Output: string without suffix
string_remove_suffix() {
    local string="$1"
    local suffix="$2"
    printf '%s\n' "${string%"$suffix"}"
}

# Escape string for shell usage
# Args: string
# Output: shell-escaped string
string_escape() {
    local string="$1"
    # Simple escaping - wrap in single quotes and escape any single quotes
    printf "'%s'\n" "${string//\'/\'\\\'\'}"
}

# Pad string to specified width
# Args: string, width, [pad_char]
# Output: padded string
string_pad_left() {
    local string="$1"
    local width="$2"
    local pad_char="${3:- }"

    local current_length=${#string}
    if [[ $current_length -ge $width ]]; then
        printf '%s\n' "$string"
        return
    fi

    local padding_needed=$((width - current_length))
    local padding
    padding=$(printf "%*s" "$padding_needed" "" | tr ' ' "$pad_char")
    printf '%s\n' "$padding$string"
}

# Pad string to specified width (right padding)
# Args: string, width, [pad_char]
# Output: padded string
string_pad_right() {
    local string="$1"
    local width="$2"
    local pad_char="${3:- }"

    local current_length=${#string}
    if [[ $current_length -ge $width ]]; then
        printf '%s\n' "$string"
        return
    fi

    local padding_needed=$((width - current_length))
    local padding
    padding=$(printf "%*s" "$padding_needed" "" | tr ' ' "$pad_char")
    printf '%s\n' "$string$padding"
}

# Truncate string to specified length
# Args: string, max_length, [suffix]
# Output: truncated string with optional suffix
string_truncate() {
    local string="$1"
    local max_length="$2"
    local suffix="${3:-...}"

    if [[ ${#string} -le $max_length ]]; then
        printf '%s\n' "$string"
        return
    fi

    local truncate_at=$((max_length - ${#suffix}))
    printf '%s\n' "${string:0:$truncate_at}$suffix"
}

# Repeat string N times
# Args: string, count
# Output: repeated string
string_repeat() {
    local string="$1"
    local count="$2"

    local i
    for ((i=0; i<count; i++)); do
        printf '%s' "$string"
    done
    printf '\n'
}

# Check if string is empty or only whitespace
# Args: string
# Returns: 0 if empty/whitespace, 1 otherwise
string_is_empty() {
    local trimmed
    trimmed="$(string_trim "$1")"
    [[ -z "$trimmed" ]]
}

# Get substring
# Args: string, start_pos, [length]
# Output: substring
string_substring() {
    local string="$1"
    local start="$2"
    local length="${3:-}"

    if [[ -n "$length" ]]; then
        printf '%s\n' "${string:$start:$length}"
    else
        printf '%s\n' "${string:$start}"
    fi
}
