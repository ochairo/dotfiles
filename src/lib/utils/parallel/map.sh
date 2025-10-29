#!/usr/bin/env bash
# parallel/map.sh - Parallel map helper

parallel_map() {
    local func="$1"; shift
    local items=("$@")
    # Simplified sequential execution; prints outputs directly
    for item in "${items[@]}"; do
        "$func" "$item"
    done
}
