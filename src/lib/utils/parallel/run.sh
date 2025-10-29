#!/usr/bin/env bash
# parallel/run.sh - Run multiple commands concurrently

parallel_run() {
    local commands=("$@")
    [[ ${#commands[@]} -eq 0 ]] && return 0

    local -a pids=()
    local tmp_dir
    tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'parallel')
    trap 'rm -rf "$tmp_dir"' EXIT

    for i in "${!commands[@]}"; do
        (
            eval "${commands[$i]}" >"$tmp_dir/$i.out" 2>"$tmp_dir/$i.err"; echo $? >"$tmp_dir/$i.exit"
        ) &
        pids+=($!)
    done

    local failed=0
    for i in "${!pids[@]}"; do
        wait "${pids[$i]}" 2>/dev/null || true
        if [[ -f "$tmp_dir/$i.exit" ]]; then
            local ec; ec=$(<"$tmp_dir/$i.exit")
            [[ $ec == 0 ]] || ((failed++))
        fi
    done
    rm -rf "$tmp_dir"
    [[ $failed -eq 0 ]]
}
