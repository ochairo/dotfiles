#!/usr/bin/env bash
# Parallel grouping

deps_group_parallel() {
    local input=("$@") level=() max_level=0
    calc_level() {
        local comp="$1" max_dep=0 dep_level
        [[ -n "${level[$comp]:-}" ]] && return 0
        if command -v components_requires >/dev/null 2>&1; then
            while IFS= read -r dep; do
                [[ -z "$dep" ]] && continue
                calc_level "$dep"
                dep_level="${level[$dep]:-0}"
                [[ $dep_level -ge $max_dep ]] && max_dep=$((dep_level+1))
            done < <(components_requires "$comp")
        fi
        level[$comp]=$max_dep; [[ $max_dep -gt $max_level ]] && max_level=$max_dep
    }
    for comp in "${input[@]}"; do calc_level "$comp"; done
    local i comp
    for ((i=0;i<=max_level;i++)); do
        [[ $i -gt 0 ]] && echo "---"
        for comp in "${input[@]}"; do [[ "${level[$comp]:-0}" -eq $i ]] && echo "$comp"; done
    done
}
