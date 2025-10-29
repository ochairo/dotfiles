#!/usr/bin/env bash
# arrays/slicing.sh - Slicing and selection operations (slice/first/last)

# Get portion of array
# Args: start_index, length, array_elements...
# Output: slice elements, one per line
array_slice() {
    local start="$1" length="$2"; shift 2
    local -a items=("$@")
    local end=$((start + length)) i
    for ((i=start; i<end && i<${#items[@]}; i++)); do
        printf '%s\n' "${items[$i]}"
    done
}

# Get first N elements
# Args: count, array_elements...
# Output: first N elements, one per line
array_first() { local count="$1"; shift; array_slice 0 "$count" "$@"; }

# Get last N elements
# Args: count, array_elements...
# Output: last N elements, one per line
array_last() {
    local count="$1"; shift
    local total=$# start=$((total - count))
    [[ $start -lt 0 ]] && start=0
    array_slice "$start" "$count" "$@"
}
