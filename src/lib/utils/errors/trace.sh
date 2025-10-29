#!/usr/bin/env bash
# errors/trace.sh - Stack trace rendering

error_trace() {
    local frame=0 func line file
    msg_error "Call stack:"
    while read -r func line file < <(caller $frame 2>/dev/null || echo ""); do
        [[ -z $func ]] && break
        if [[ $func != error_trace && $func != error_handler && $func != error_exit ]]; then
            msg_error "  at ${func}() [$file:$line]"
        fi
        ((frame++)); [[ $frame -gt 20 ]] && break
    done
    if [[ ${#ERROR_CONTEXT_STACK[@]} -gt 0 ]]; then
        msg_error "Context:"
        local c; for c in "${ERROR_CONTEXT_STACK[@]}"; do msg_error "  $c"; done
    fi
}
