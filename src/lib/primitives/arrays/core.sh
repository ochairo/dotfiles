#!/usr/bin/env bash
# arrays/core.sh - Core array operations (containment, length, join, uniqueness, filter, map, take/skip, append/remove, emptiness)

# Check if array contains element
# Args: element, array_elements...
# Returns: 0 if found, 1 if not found
array_contains() {
    local element="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" == "$element" ]] && return 0
    done
    return 1
}

# Get array length
# Args: array_elements...
# Output: number of elements
array_length() { echo "$#"; }

# Join array elements with delimiter
# Args: delimiter, array_elements...
# Output: joined string
array_join() {
    local delimiter="$1"; shift
    local first=1 item
    for item in "$@"; do
        if [[ $first -eq 1 ]]; then
            printf '%s' "$item"; first=0
        else
            printf '%s%s' "$delimiter" "$item"
        fi
    done
    printf '\n'
}

# Remove duplicate elements (preserves order)
# Args: array_elements...
# Output: unique elements, one per line
array_unique() {
    local seen="" item
    for item in "$@"; do
        if [[ ":$seen:" != *":$item:"* ]]; then
            printf '%s\n' "$item"
            seen="${seen}:$item"
        fi
    done
}

## (Moved functional helpers: filter/map/take/skip/append/remove/is_empty to functional.sh)
