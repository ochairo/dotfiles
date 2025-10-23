#!/usr/bin/env bash
# dependencies.sh - Component dependency resolution
# Handles topological sorting and circular dependency detection

# Prevent double loading
[[ -n "${DOTFILES_DEPENDENCIES_LOADED:-}" ]] && return 0
readonly DOTFILES_DEPENDENCIES_LOADED=1

# Resolve dependencies to install order
# Args: component_names (array or space-separated)
# Returns: ordered component list (one per line)
# Example: deps_resolve "neovim git"
deps_resolve() {
    local input=("$@")
    local -A visited=()
    local -A in_progress=()
    local result=()

    # DFS helper function
    # shellcheck disable=SC2034
    local visit_component
    visit_component() {
        local comp="${1}"

        # Check for circular dependency
        if [[ -n "${in_progress[$comp]:-}" ]]; then
            return 1  # Circular dependency detected
        fi

        # Already processed
        if [[ -n "${visited[$comp]:-}" ]]; then
            return 0
        fi

        # Check component exists
        if ! command -v components_exists >/dev/null 2>&1 || ! components_exists "$comp"; then
            return 1
        fi

        # Mark as in progress
        in_progress[$comp]=1

        # Process dependencies recursively
        if command -v components_requires >/dev/null 2>&1; then
            while IFS= read -r dep; do
                [[ -z "$dep" ]] && continue
                if ! visit_component "$dep"; then
                    return 1
                fi
            done < <(components_requires "$comp")
        fi

        # Mark as visited
        unset "in_progress[$comp]"
        visited[$comp]=1
        result+=("$comp")

        return 0
    }

    # Process each input component
    for comp in "${input[@]}"; do
        if ! visit_component "$comp"; then
            return 1
        fi
    done

    # Output in order
    printf '%s\n' "${result[@]}"
}

# Check for circular dependencies
# Args: component_name
# Returns: 0 if no cycle, 1 if cycle detected
# Example: if ! deps_has_cycle "git"; then echo "No cycle"; fi
deps_has_cycle() {
    local start="${1}"
    local -A visited=()
    local -A stack=()

    # shellcheck disable=SC2034
    local check_cycle
    check_cycle() {
        local comp="${1}"

        # Found cycle
        if [[ -n "${stack[$comp]:-}" ]]; then
            return 1
        fi

        # Already checked this path
        if [[ -n "${visited[$comp]:-}" ]]; then
            return 0
        fi

        stack[$comp]=1

        # Check dependencies
        if command -v components_requires >/dev/null 2>&1; then
            while IFS= read -r dep; do
                [[ -z "$dep" ]] && continue
                if ! check_cycle "$dep"; then
                    return 1
                fi
            done < <(components_requires "$comp")
        fi

        unset "stack[$comp]"
        visited[$comp]=1

        return 0
    }

    check_cycle "$start"
}

# Find cycle path if circular dependency exists
# Args: component_name
# Returns: cycle path (component -> component -> ...)
# Example: deps_find_cycle "comp-a"
deps_find_cycle() {
    local start="${1}"
    local -A visited=()
    local -a path=()

    # shellcheck disable=SC2034
    local find_path
    find_path() {
        local comp="${1}"

        # Check if we've seen this before in current path
        for ((i=0; i<${#path[@]}; i++)); do
            if [[ "${path[$i]}" == "$comp" ]]; then
                # Found cycle - print from cycle start
                local cycle_path=""
                for ((j=i; j<${#path[@]}; j++)); do
                    [[ -n "$cycle_path" ]] && cycle_path+=" -> "
                    cycle_path+="${path[$j]}"
                done
                cycle_path+=" -> $comp"
                echo "$cycle_path"
                return 0
            fi
        done

        # Already fully explored
        if [[ -n "${visited[$comp]:-}" ]]; then
            return 1
        fi

        path+=("$comp")

        # Explore dependencies
        if command -v components_requires >/dev/null 2>&1; then
            while IFS= read -r dep; do
                [[ -z "$dep" ]] && continue
                if find_path "$dep"; then
                    return 0
                fi
            done < <(components_requires "$comp")
        fi

        visited[$comp]=1
        unset 'path[-1]'

        return 1
    }

    find_path "$start"
}

# Get all transitive dependencies
# Args: component_name
# Returns: all dependencies (one per line)
# Example: deps_all "neovim"
deps_all() {
    local comp="${1}"
    local -A seen=()

    # shellcheck disable=SC2034
    local collect_deps
    collect_deps() {
        local c="${1}"

        [[ -n "${seen[$c]:-}" ]] && return 0
        seen[$c]=1

        if command -v components_requires >/dev/null 2>&1; then
            while IFS= read -r dep; do
                [[ -z "$dep" ]] && continue
                echo "$dep"
                collect_deps "$dep"
            done < <(components_requires "$c")
        fi
    }

    collect_deps "$comp" | sort -u
}

# Get direct dependencies only
# Args: component_name
# Returns: direct dependencies (one per line)
# Example: deps_direct "neovim"
deps_direct() {
    local comp="${1}"

    if command -v components_requires >/dev/null 2>&1; then
        components_requires "$comp"
    fi
}

# Check if component A depends on B
# Args: component_a, component_b
# Returns: 0 if A depends on B, 1 otherwise
# Example: if deps_depends_on "neovim" "fonts"; then echo "Depends"; fi
deps_depends_on() {
    local comp_a="${1}"
    local comp_b="${2}"

    deps_all "$comp_a" | grep -qxF "$comp_b"
}

# Get reverse dependencies (what depends on this component)
# Args: component_name
# Returns: components that depend on this one (one per line)
# Example: deps_reverse "fonts"
deps_reverse() {
    local target="${1}"

    if ! command -v components_list >/dev/null 2>&1; then
        return 1
    fi

    components_list | while read -r comp; do
        if deps_depends_on "$comp" "$target"; then
            echo "$comp"
        fi
    done
}

# Get dependency tree as indented text
# Args: component_name, [indent_level]
# Returns: formatted tree
# Example: deps_tree "neovim"
deps_tree() {
    local comp="${1}"
    local indent="${2:-0}"
    local -A seen=()

    # shellcheck disable=SC2034
    local print_tree
    print_tree() {
        local c="${1}"
        local lvl="${2}"
        local prefix=""

        # Create indentation
        for ((i=0; i<lvl; i++)); do
            prefix="  $prefix"
        done

        echo "${prefix}${c}"

        # Mark as seen to avoid infinite loops
        if [[ -n "${seen[$c]:-}" ]]; then
            echo "${prefix}  (already shown above)"
            return 0
        fi
        seen[$c]=1

        # Print dependencies
        if command -v components_requires >/dev/null 2>&1; then
            while IFS= read -r dep; do
                [[ -z "$dep" ]] && continue
                print_tree "$dep" $((lvl + 1))
            done < <(components_requires "$c")
        fi
    }

    print_tree "$comp" "$indent"
}

# Validate all dependencies exist
# Args: component_name
# Returns: 0 if all deps exist, 1 otherwise (prints missing deps)
# Example: if ! deps_validate "neovim"; then echo "Missing deps"; fi
deps_validate() {
    local comp="${1}"
    local missing=0

    if ! command -v components_requires >/dev/null 2>&1; then
        return 1
    fi

    while IFS= read -r dep; do
        [[ -z "$dep" ]] && continue
        if ! command -v components_exists >/dev/null 2>&1 || ! components_exists "$dep"; then
            echo "$dep"
            missing=1
        fi
    done < <(components_requires "$comp")

    return $missing
}

# Get install order for multiple components
# Args: component_names...
# Returns: ordered list (one per line)
# Example: deps_install_order "neovim" "git" "zsh"
deps_install_order() {
    deps_resolve "$@"
}

# Group components by dependency level (for parallel execution)
# Args: component_names...
# Returns: groups separated by "---"
# Example: deps_group_parallel "comp1" "comp2" "comp3"
deps_group_parallel() {
    local input=("$@")
    local -A level=()
    local max_level=0

    # Calculate depth for each component
    # shellcheck disable=SC2034
    local calc_level
    calc_level() {
        local comp="${1}"

        # Already calculated
        if [[ -n "${level[$comp]:-}" ]]; then
            return 0
        fi

        local max_dep_level=0

        # Find max level of dependencies
        if command -v components_requires >/dev/null 2>&1; then
            while IFS= read -r dep; do
                [[ -z "$dep" ]] && continue
                calc_level "$dep"
                local dep_level="${level[$dep]:-0}"
                if [[ $dep_level -ge $max_dep_level ]]; then
                    max_dep_level=$((dep_level + 1))
                fi
            done < <(components_requires "$comp")
        fi

        level[$comp]=$max_dep_level
        if [[ $max_dep_level -gt $max_level ]]; then
            max_level=$max_dep_level
        fi
    }

    # Calculate levels
    for comp in "${input[@]}"; do
        calc_level "$comp"
    done

    # Output grouped by level
    for ((i=0; i<=max_level; i++)); do
        [[ $i -gt 0 ]] && echo "---"
        for comp in "${input[@]}"; do
            if [[ "${level[$comp]:-0}" -eq $i ]]; then
                echo "$comp"
            fi
        done
    done
}
