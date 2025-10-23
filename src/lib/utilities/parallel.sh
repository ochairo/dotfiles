#!/usr/bin/env bash
# parallel.sh - Parallel task execution with worker pool
# Reusable across any shell script project (macOS and Linux compatible)

# Prevent double loading
[[ -n "${INSTALL_PARALLEL_LOADED:-}" ]] && return 0
readonly INSTALL_PARALLEL_LOADED=1

# Default number of parallel workers
: "${PARALLEL_WORKERS:=4}"

# Execute tasks in parallel with worker pool
# Args: max_workers, task_function, task_args_array
# Returns: 0 if all success, 1 if any failure
# Example: parallel_execute 4 "install_pkg" "${packages[@]}"
parallel_execute() {
    local max_workers="${1}"
    shift
    local task_func="${1}"
    shift
    local tasks=("$@")

    if [[ ${#tasks[@]} -eq 0 ]]; then
        return 0
    fi

    local total=${#tasks[@]}
    local completed=0
    local failed=0
    local active_jobs=0
    local job_pids=()

    # Create temp directory for job results
    local tmp_dir
    tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'parallel')

    # Cleanup on exit
    # shellcheck disable=SC2064
    trap "rm -rf '$tmp_dir'" EXIT

    # Execute task in background
    _run_task() {
        local task="${1}"
        local idx="${2}"
        local result_file="${tmp_dir}/${idx}.result"

        if $task_func "$task" >"${tmp_dir}/${idx}.out" 2>"${tmp_dir}/${idx}.err"; then
            echo "0" > "$result_file"
        else
            echo "1" > "$result_file"
        fi
    }

    # Start initial batch of workers
    for ((i=0; i<total; i++)); do
        # Wait if we're at max workers
        while [[ $active_jobs -ge $max_workers ]]; do
            # Check for completed jobs
            for pid_idx in "${!job_pids[@]}"; do
                local pid="${job_pids[$pid_idx]}"
                if ! kill -0 "$pid" 2>/dev/null; then
                    wait "$pid" 2>/dev/null || true

                    # Check result
                    if [[ -f "${tmp_dir}/${pid_idx}.result" ]]; then
                        local result
                        result=$(cat "${tmp_dir}/${pid_idx}.result")
                        if [[ "$result" == "0" ]]; then
                            ((completed++))
                        else
                            ((failed++))
                        fi
                    fi

                    # Remove from active jobs
                    unset "job_pids[$pid_idx]"
                    ((active_jobs--))
                fi
            done
            sleep 0.1
        done

        # Start new task
        _run_task "${tasks[$i]}" "$i" &
        job_pids[$i]=$!
        ((active_jobs++))
    done

    # Wait for remaining jobs
    for pid_idx in "${!job_pids[@]}"; do
        local pid="${job_pids[$pid_idx]}"
        wait "$pid" 2>/dev/null || true

        if [[ -f "${tmp_dir}/${pid_idx}.result" ]]; then
            local result
            result=$(cat "${tmp_dir}/${pid_idx}.result")
            if [[ "$result" == "0" ]]; then
                ((completed++))
            else
                ((failed++))
            fi
        fi
    done

    # Cleanup
    rm -rf "$tmp_dir"

    [[ $failed -eq 0 ]]
}

# Simple parallel map - execute function on each item in parallel
# Args: function_name, item1, item2, ...
# Returns: 0 if all success, 1 if any failure
# Example: parallel_map "process_file" file1.txt file2.txt file3.txt
parallel_map() {
    local func="${1}"
    shift
    local items=("$@")

    parallel_execute "$PARALLEL_WORKERS" "$func" "${items[@]}"
}

# Execute function for each line in file (parallel)
# Args: function_name, input_file, max_workers (default: PARALLEL_WORKERS)
# Returns: 0 if all success, 1 if any failure
# Example: parallel_foreach "process_line" input.txt 8
parallel_foreach() {
    local func="${1}"
    local input_file="${2}"
    local workers="${3:-$PARALLEL_WORKERS}"

    if [[ ! -f "$input_file" ]]; then
        return 1
    fi

    local lines=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && lines+=("$line")
    done < "$input_file"

    parallel_execute "$workers" "$func" "${lines[@]}"
}

# Run commands in parallel with output capture
# Args: command1, command2, ..., commandN
# Returns: 0 if all success, 1 if any failure
# Example: parallel_run "make test" "npm install" "cargo build"
parallel_run() {
    local commands=("$@")

    if [[ ${#commands[@]} -eq 0 ]]; then
        return 0
    fi

    local pids=()
    local tmp_dir
    tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'parallel')

    # shellcheck disable=SC2064
    trap "rm -rf '$tmp_dir'" EXIT

    # Start all commands
    for i in "${!commands[@]}"; do
        (
            eval "${commands[$i]}" > "${tmp_dir}/${i}.out" 2> "${tmp_dir}/${i}.err"
            echo $? > "${tmp_dir}/${i}.exit"
        ) &
        pids+=($!)
    done

    # Wait for all to complete
    local failed=0
    for i in "${!pids[@]}"; do
        wait "${pids[$i]}" || true

        if [[ -f "${tmp_dir}/${i}.exit" ]]; then
            local exit_code
            exit_code=$(cat "${tmp_dir}/${i}.exit")
            if [[ "$exit_code" != "0" ]]; then
                ((failed++))
            fi
        fi
    done

    rm -rf "$tmp_dir"
    [[ $failed -eq 0 ]]
}

# Get optimal number of parallel workers based on CPU cores
# Args: multiplier (default: 1.0)
# Returns: number of workers
# Example: workers=$(parallel_optimal_workers 1.5)
parallel_optimal_workers() {
    local multiplier="${1:-1.0}"
    local cores

    if [[ "$(uname -s)" == "Darwin" ]]; then
        cores=$(sysctl -n hw.ncpu 2>/dev/null || echo "4")
    else
        cores=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "4")
    fi

    # Calculate workers (cores * multiplier)
    local workers
    workers=$(awk -v c="$cores" -v m="$multiplier" 'BEGIN {printf "%.0f", c * m}')

    # Ensure at least 1 worker
    [[ $workers -lt 1 ]] && workers=1

    echo "$workers"
}

# Set global parallel workers count
# Args: count (if omitted, uses optimal)
# Example: parallel_set_workers 8
parallel_set_workers() {
    local count="${1:-$(parallel_optimal_workers)}"
    export PARALLEL_WORKERS="$count"
}
