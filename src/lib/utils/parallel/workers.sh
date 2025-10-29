#!/usr/bin/env bash
# parallel/workers.sh - Worker count helpers

parallel_optimal_workers() {
    local multiplier="${1:-1.0}" cores workers
    if [[ $(uname -s) == Darwin ]]; then
        cores=$(sysctl -n hw.ncpu 2>/dev/null || echo 4)
    else
        cores=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || echo 4)
    fi
    workers=$(awk -v c="$cores" -v m="$multiplier" 'BEGIN{printf "%.0f", c*m}')
    [[ $workers -lt 1 ]] && workers=1
    echo "$workers"
}

parallel_set_workers() {
    local count="${1:-$(parallel_optimal_workers)}"
    export PARALLEL_WORKERS="$count"
}
