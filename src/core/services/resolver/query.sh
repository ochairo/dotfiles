#!/usr/bin/env bash
# Dependency queries & tree

deps_all() {
    local comp="$1"; local -A seen=()
    collect() {
        local c="$1"; [[ -n "${seen[$c]:-}" ]] && return 0; seen[$c]=1
        if command -v components_requires >/dev/null 2>&1; then
            while IFS= read -r dep; do
                [[ -z "$dep" ]] && continue
                echo "$dep"; collect "$dep"
            done < <(components_requires "$c")
        fi
    }
    collect "$comp" | sort -u
}

deps_direct() { command -v components_requires >/dev/null 2>&1 && components_requires "$1"; }

deps_depends_on() { deps_all "$1" | grep -qxF "$2"; }

deps_reverse() {
    local target="$1"; command -v components_list >/dev/null 2>&1 || return 1
    components_list | while read -r comp; do deps_depends_on "$comp" "$target" && echo "$comp"; done
}

deps_tree() {
    local comp="$1"; local indent="${2:-0}"; local -A seen=()
    print_tree() {
        local c="$1" lvl="$2" prefix=""; local i
        for ((i=0;i<lvl;i++)); do prefix="  $prefix"; done
        echo "${prefix}${c}"; [[ -n "${seen[$c]:-}" ]] && { echo "${prefix}  (already shown above)"; return 0; }
        seen[$c]=1
        if command -v components_requires >/dev/null 2>&1; then
            while IFS= read -r dep; do [[ -z "$dep" ]] && continue; print_tree "$dep" $((lvl+1)); done < <(components_requires "$c")
        fi
    }
    print_tree "$comp" "$indent"
}

deps_validate() {
    local comp="$1" missing=0
    command -v components_requires >/dev/null 2>&1 || return 1
    while IFS= read -r dep; do
        [[ -z "$dep" ]] && continue
        if ! command -v components_exists >/dev/null 2>&1 || ! components_exists "$dep"; then echo "$dep"; missing=1; fi
    done < <(components_requires "$comp")
    return $missing
}
