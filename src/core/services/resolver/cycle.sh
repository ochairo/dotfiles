#!/usr/bin/env bash
# Cycle detection utilities

deps_has_cycle() {
    local start="$1"; local -A visited=() stack=()
    check_cycle() {
        local comp="$1"
        [[ -n "${stack[$comp]:-}" ]] && return 1
        [[ -n "${visited[$comp]:-}" ]] && return 0
        stack[$comp]=1
        if command -v components_requires >/dev/null 2>&1; then
            while IFS= read -r dep; do
                [[ -z "$dep" ]] && continue
                check_cycle "$dep" || return 1
            done < <(components_requires "$comp")
        fi
        unset "stack[$comp]"; visited[$comp]=1; return 0
    }
    check_cycle "$start"
}

deps_find_cycle() {
    local start="$1"; local -A visited=(); local -a path=()
    find_path() {
        local comp="$1"; local i j
        for ((i=0;i<${#path[@]};i++)); do
            if [[ "${path[$i]}" == "$comp" ]]; then
                local cycle=""; for ((j=i;j<${#path[@]};j++)); do [[ -n "$cycle" ]] && cycle+=" -> "; cycle+="${path[$j]}"; done
                cycle+=" -> $comp"; echo "$cycle"; return 0
            fi
        done
        [[ -n "${visited[$comp]:-}" ]] && return 1
        path+=("$comp")
        if command -v components_requires >/dev/null 2>&1; then
            while IFS= read -r dep; do
                [[ -z "$dep" ]] && continue
                find_path "$dep" && return 0
            done < <(components_requires "$comp")
        fi
        visited[$comp]=1; unset 'path[-1]'; return 1
    }
    find_path "$start"
}
