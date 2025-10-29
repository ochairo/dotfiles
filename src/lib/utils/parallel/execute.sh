#!/usr/bin/env bash
# parallel/execute.sh - Core worker pool executor

parallel_execute() {
    local max_workers="$1"; shift
    local task_func="$1"; shift
    local tasks=("$@")

    [[ ${#tasks[@]} -eq 0 ]] && return 0

    local total=${#tasks[@]} completed=0 failed=0 active_jobs=0
    local -a job_pids=()

    local tmp_dir
    tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'parallel')
    trap 'rm -rf "$tmp_dir"' EXIT

    _parallel_run_task() {
        local task="$1"
        local idx="$2"
        local result_file="$tmp_dir/$idx.result"
        if $task_func "$task" >"$tmp_dir/$idx.out" 2>"$tmp_dir/$idx.err"; then
            echo 0 >"$result_file"
        else
            echo 1 >"$result_file"
        fi
    }

    for ((i=0;i<total;i++)); do
        while [[ $active_jobs -ge $max_workers ]]; do
            for pid_idx in "${!job_pids[@]}"; do
                local pid="${job_pids[$pid_idx]}"
                if ! kill -0 "$pid" 2>/dev/null; then
                    wait "$pid" 2>/dev/null || true
                    if [[ -f "$tmp_dir/$pid_idx.result" ]]; then
                        if [[ $(<"$tmp_dir/$pid_idx.result") == 0 ]]; then
                            ((completed++))
                        else
                            ((failed++))
                        fi
                    fi
                    unset "job_pids[$pid_idx]"; ((active_jobs--))
                fi
            done
            sleep 0.05
        done
        _parallel_run_task "${tasks[$i]}" "$i" &
        job_pids[$i]=$!; ((active_jobs++))
    done

    for pid_idx in "${!job_pids[@]}"; do
        wait "${job_pids[$pid_idx]}" 2>/dev/null || true
        if [[ -f "$tmp_dir/$pid_idx.result" ]]; then
            if [[ $(<"$tmp_dir/$pid_idx.result") == 0 ]]; then
                ((completed++))
            else
                ((failed++))
            fi
        fi
    done

    rm -rf "$tmp_dir"
    [[ $failed -eq 0 ]]
}
