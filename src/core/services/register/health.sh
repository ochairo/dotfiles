#!/usr/bin/env bash
# register/health.sh - Health check extraction and execution
components_health_check() {
    local raw
    raw=$(components_get_field "$1" "healthCheck" || echo "")
    if [[ ${#raw} -ge 2 ]]; then
        case "$raw" in
            '"'*'"') raw=${raw:1:${#raw}-2} ;;
            "'*'"*) raw=${raw:1:${#raw}-2} ;;
        esac
    fi
    printf '%s' "$raw"
}
components_check_health() {
    local name="$1" check
    check=$(components_health_check "$name")
    [[ -n "$check" ]] || return 1
    eval "$check" >/dev/null 2>&1
}

# Compatibility shim for legacy function name used by CLI commands
registry_health_check() {
    components_health_check "$1"
}
export -f registry_health_check
