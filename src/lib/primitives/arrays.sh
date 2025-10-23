#!/usr/bin/env bash
# arrays.sh - Comprehensive array manipulation utilities
# Reusable across any shell script project (macOS and Linux compatible)

# Prevent double loading
[[ -n "${ARRAYS_LOADED:-}" ]] && return 0
readonly ARRAYS_LOADED=1

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
array_length() {
    echo "$#"
}

# Join array elements with delimiter
# Args: delimiter, array_elements...
# Output: joined string
array_join() {
    local delimiter="$1"
    shift

    local first=1
    local item
    for item in "$@"; do
        if [[ $first -eq 1 ]]; then
            printf '%s' "$item"
            first=0
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
    local seen=""
    local item
    for item in "$@"; do
        if [[ ":$seen:" != *":$item:"* ]]; then
            printf '%s\n' "$item"
            seen="${seen}:${item}"
        fi
    done
}

# Filter array elements by pattern
# Args: pattern, array_elements...
# Output: matching elements, one per line
array_filter() {
    local pattern="$1"
    shift
    local item
    for item in "$@"; do
        if [[ "$item" =~ $pattern ]]; then
            printf '%s\n' "$item"
        fi
    done
}

# Map function over array elements
# Args: function_name, array_elements...
# Output: function results, one per line
array_map() {
    local func="$1"
    shift
    local item
    for item in "$@"; do
        "$func" "$item"
    done
}

# Get first N elements
# Args: count, array_elements...
# Output: first N elements, one per line
array_take() {
    local count="$1"
    shift
    local i=0
    local item
    for item in "$@"; do
        [[ $i -ge $count ]] && break
        printf '%s\n' "$item"
        ((i++))
    done
}

# Skip first N elements
# Args: count, array_elements...
# Output: remaining elements, one per line
array_skip() {
    local count="$1"
    shift
    local i=0
    local item
    for item in "$@"; do
        if [[ $i -ge $count ]]; then
            printf '%s\n' "$item"
        fi
        ((i++))
    done
}

# Append element if not already present
# Args: element, array_elements...
# Output: array with element added (if not present), one per line
array_append_unique() {
    local element="$1"
    shift
    printf '%s\n' "$@"
    if ! array_contains "$element" "$@"; then
        printf '%s\n' "$element"
    fi
}

# Remove element from array
# Args: element, array_elements...
# Output: array without element, one per line
array_remove() {
    local element="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" != "$element" ]] && printf '%s\n' "$item"
    done
}

# Check if array is empty
# Args: array_elements...
# Returns: 0 if empty, 1 if not empty
array_is_empty() {
    [[ $# -eq 0 ]]
}

# Add element to end (push)
# Args: array_name, element
array_push() {
    local array_name="$1"
    local element="$2"
    eval "${array_name}+=(\"\$element\")"
}

# Remove and return last element (pop)
# Args: array_name
# Output: last element
array_pop() {
    local array_name="$1"

    # Check if array is empty
    local length
    eval "length=\${#${array_name}[@]}"

    if [[ $length -eq 0 ]]; then
        return 1
    fi

    local last_index=$((length - 1))
    eval "printf '%s\\n' \"\${${array_name}[$last_index]}\""
    eval "unset \"${array_name}[$last_index]\""
}

# Remove and return first element (shift)
# Args: array_name
# Output: first element
array_shift() {
    local array_name="$1"

    # Check if array is empty
    local length
    eval "length=\${#${array_name}[@]}"

    if [[ $length -eq 0 ]]; then
        return 1
    fi

    eval "printf '%s\\n' \"\${${array_name}[0]}\""
    eval "${array_name}=(\"\${${array_name}[@]:1}\")"
}

# Add element to beginning (unshift)
# Args: array_name, element
array_unshift() {
    local array_name="$1"
    local element="$2"
    eval "${array_name}=(\"\$element\" \"\${${array_name}[@]}\")"
}

# Get portion of array
# Args: start_index, length, array_elements...
# Output: slice elements, one per line
array_slice() {
    local start="$1"
    local length="$2"
    shift 2

    local -a items=("$@")
    local end=$((start + length))
    local i

    for ((i=start; i<end && i<${#items[@]}; i++)); do
        printf '%s\n' "${items[$i]}"
    done
}

# Get first N elements
# Args: count, array_elements...
# Output: first N elements, one per line
array_first() {
    local count="$1"
    shift
    array_slice 0 "$count" "$@"
}

# Get last N elements
# Args: count, array_elements...
# Output: last N elements, one per line
array_last() {
    local count="$1"
    shift
    local total=$#
    local start=$((total - count))
    [[ $start -lt 0 ]] && start=0
    array_slice "$start" "$count" "$@"
}

# Split arguments into two arrays using separator
# Args: separator, array1_elements..., separator, array2_elements...
# Sets: _ARRAY1 and _ARRAY2 global arrays
_array_split_args() {
    local separator="$1"
    shift

    _ARRAY1=()
    _ARRAY2=()
    local in_second=0

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
_array_is_numeric() {
    [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]
}

# Get array intersection (elements in both arrays)
# Args: separator, array1_elements..., separator, array2_elements...
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

# Get elements in first array but not in second
# Args: separator, array1_elements..., separator, array2_elements...
# Output: difference elements, one per line
array_diff() {
    _array_split_args "$@"

    local item
    for item in "${_ARRAY1[@]}"; do
        if ! array_contains "$item" "${_ARRAY2[@]}"; then
            printf '%s\n' "$item"
        fi
    done
}

# Get union of two arrays (all unique elements)
# Args: separator, array1_elements..., separator, array2_elements...
# Output: union elements, one per line
array_union() {
    _array_split_args "$@"
    array_unique "${_ARRAY1[@]}" "${_ARRAY2[@]}"
}

# Flatten nested arrays (space-separated strings become individual elements)
# Args: array_elements... (some may be space-separated strings)
# Output: flattened elements, one per line
array_flatten() {
    local item
    for item in "$@"; do
        printf '%s\n' "$item"  # Intentionally unquoted to split on spaces
    done
}

# Remove empty/null elements
# Args: array_elements...
# Output: non-empty elements, one per line
array_compact() {
    local item
    for item in "$@"; do
        if [[ -n "$item" ]]; then
            printf '%s\n' "$item"
        fi
    done
}

# Associative array helper: check if key exists
# Args: key, associative_array_name
# Returns: 0 if key exists, 1 if not
assoc_has_key() {
    local key="$1"
    local array_name="$2"

    # Check if array exists and key is set
    if declare -p "$array_name" &>/dev/null; then
        # Use eval to check if key exists (safer than nameref for static analysis)
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
        # Use eval to get keys (safer than nameref for static analysis)
        eval "printf '%s\\n' \"\${!${array_name}[@]}\""
    fi
}

# Associative array helper: get all values
# Args: associative_array_name
# Output: values, one per line
assoc_values() {
    local array_name="$1"

    if declare -p "$array_name" &>/dev/null; then
        # Use eval to get values (safer than nameref for static analysis)
        eval "printf '%s\\n' \"\${${array_name}[@]}\""
    fi
}
