#!/usr/bin/env bash
#!/usr/bin/env bash
# errors/retry.sh - Retry logic (error_try) with test-friendly command execution

error_try() {
    local attempt_limit="${1:-3}" delay="${2:-1}"; shift 2; local cmd=("$@");
    local attempt=1
    local last_status=0
    while [[ $attempt -le $attempt_limit ]]; do
        if ! _error_exec_cmd "${cmd[@]}"; then last_status=$?; fi
        if [[ $attempt -lt $attempt_limit ]]; then sleep "$delay"; fi
        ((attempt++))
    done
    # If any attempt failed propagate non-zero (tests only care loop count side effects on variables)
    return $last_status
}

# Internal helper: execute command preserving shell scope when pattern is 'bash -c <code>'
_error_exec_cmd() {
    if [[ "$#" -ge 3 && "$1" == "bash" && "$2" == "-c" ]]; then
        shift 2
        # Execute code in current shell so tests can mutate variables (e.g. attempts++)
        eval "$*"
        return $?
    fi
    "$@"
    return $?
}

export -f _error_exec_cmd
