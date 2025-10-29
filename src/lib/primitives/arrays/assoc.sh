#!/usr/bin/env bash
# arrays/assoc.sh - Associative array helpers (has_key, keys, values)

# Associative array helper: check if key exists
# Args: key, associative_array_name
# Returns: 0 if key exists, 1 if not
assoc_has_key() {
    local key="$1" array_name="$2"
    if declare -p "$array_name" &>/dev/null; then
        eval "[[ -n \"\${${array_name}[$key]+isset}\" ]]"
    else
        return 1
    fi
}

# Associative array helper: get all keys
# Args: associative_array_name
# Output: keys, one per line
assoc_keys() {
    local array_name="$1"
    if declare -p "$array_name" &>/dev/null; then
        eval "printf '%s\\n' \"\${!${array_name}[@]}\""
    fi
}

# Associative array helper: get all values
# Args: associative_array_name
# Output: values, one per line
assoc_values() {
    local array_name="$1"
    if declare -p "$array_name" &>/dev/null; then
        eval "printf '%s\\n' \"\${${array_name}[@]}\""
    fi
}
