#!/usr/bin/env bash
# arrays/setops.sh - Set operations, flattening, compaction, internal helpers

# Split arguments into two arrays using separator
# Args: separator, array1..., separator, array2...
# Sets: _ARRAY1 and _ARRAY2 global arrays
_array_split_args() {
    local separator="$1"; shift
    _ARRAY1=() _ARRAY2=() local in_second=0 arg
    for arg in "$@"; do
        if [[ "$arg" == "$separator" ]]; then
            in_second=1
        elif [[ $in_second -eq 0 ]]; then
            _ARRAY1+=("$arg")
        else
            _ARRAY2+=("$arg")
        fi
    done
}

# Check if value is numeric
# Args: value
# Returns: 0 if numeric, 1 otherwise
_array_is_numeric() { [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; }

# Get array intersection
# Args: separator, array1..., separator, array2...
# Output: common elements, one per line
array_intersect() {
    _array_split_args "$@"
    local item
    for item in "${_ARRAY1[@]}"; do
        if array_contains "$item" "${_ARRAY2[@]}"; then
            printf '%s\n' "$item"
        fi
    done
}

# Get elements in first array but not second
# Args: separator, array1..., separator, array2...
array_diff() {
    _array_split_args "$@"
    local item
    for item in "${_ARRAY1[@]}"; do
        if ! array_contains "$item" "${_ARRAY2[@]}"; then
            printf '%s\n' "$item"
        fi
    done
}

# Get union of two arrays (unique)
# Args: separator, array1..., separator, array2...
array_union() { _array_split_args "$@"; array_unique "${_ARRAY1[@]}" "${_ARRAY2[@]}"; }

# Flatten nested arrays (space-separated strings become individual elements)
# Args: array_elements...
array_flatten() { local item; for item in "$@"; do printf '%s\n' "$item"; done; }

# Remove empty/null elements
# Args: array_elements...
array_compact() { local item; for item in "$@"; do [[ -n "$item" ]] && printf '%s\n' "$item"; done; }
