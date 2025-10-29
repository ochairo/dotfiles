#!/usr/bin/env bash
# parallel/foreach.sh - Apply function to each line of file in parallel

parallel_foreach() {
    local func="$1" input_file="$2" workers="${3:-$PARALLEL_WORKERS}"
    [[ -f "$input_file" ]] || return 1
    local -a lines=()
    while IFS= read -r line; do [[ -n $line ]] && lines+=("$line"); done <"$input_file"
    parallel_execute "$workers" "$func" "${lines[@]}"
}
