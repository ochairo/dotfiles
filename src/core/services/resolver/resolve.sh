#!/usr/bin/env bash
# Dependency resolution core

deps_resolve() {
    local input=("$@")
    local -A visited=() in_progress=()
    local result=()
    visit_component() {
        local comp="$1"
        [[ -n "${in_progress[$comp]:-}" ]] && return 1
        [[ -n "${visited[$comp]:-}" ]] && return 0
        if ! command -v components_exists >/dev/null 2>&1 || ! components_exists "$comp"; then
            return 1
        fi
        in_progress[$comp]=1
        if command -v components_requires >/dev/null 2>&1; then
            while IFS= read -r dep; do
                [[ -z "$dep" ]] && continue
                visit_component "$dep" || return 1
            done < <(components_requires "$comp")
        fi
        unset "in_progress[$comp]"
        visited[$comp]=1
        result+=("$comp")
        return 0
    }
    for comp in "${input[@]}"; do visit_component "$comp" || return 1; done
    printf '%s\n' "${result[@]}"
}

deps_install_order() { deps_resolve "$@"; }
