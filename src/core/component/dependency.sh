#!/usr/bin/env bash
# core/dependency.sh - Dependency resolution and topological sorting
set -euo pipefail

# Use consistent DOTFILES_ROOT calculation
DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "$DOTFILES_ROOT/core/init/constants.sh"
source "$DOTFILES_ROOT/core/io/log.sh"
source "$DOTFILES_ROOT/core/component/registry.sh"

# =============================================================================
# DEPENDENCY GRAPH FUNCTIONS
# =============================================================================

# Perform topological sort on components to determine installation order
topological_sort() {
    local components=("$@")
    local -A graph=()
    local -A in_degree=()
    local queue=()
    local result=()

    # If no components specified, use all components
    if [[ ${#components[@]} -eq 0 ]]; then
        mapfile -t components < <(registry_list_components)
    fi

    log_debug "Building dependency graph for ${#components[@]} components"

    # Build dependency graph for specified components only
    for component in "${components[@]}"; do
        if [[ ! -d "$COMPONENTS_DIR/$component" ]]; then
            log_error "Component '$component' does not exist"
            return 1
        fi

        graph["$component"]=""
        in_degree["$component"]=0
    done

    # Build edges and calculate in-degrees
    for component in "${components[@]}"; do
        local deps
        mapfile -t deps < <(registry_requires "$component")

        for dep in "${deps[@]}"; do
            [[ -n "$dep" ]] || continue

            # Only consider dependencies that are in our component list
            local found=false
            for comp in "${components[@]}"; do
                if [[ "$comp" == "$dep" ]]; then
                    found=true
                    break
                fi
            done

            if [[ "$found" == true ]]; then
                # Add edge: dep -> component
                if [[ -n "${graph["$dep"]}" ]]; then
                    graph["$dep"]="${graph["$dep"]} $component"
                else
                    graph["$dep"]="$component"
                fi

                # Increment in-degree for component
                in_degree["$component"]=$((in_degree["$component"] + 1))
            else
                log_warn "Component '$component' depends on '$dep' which is not in the installation set"
            fi
        done
    done

    # Find all nodes with in-degree 0 (no dependencies)
    for component in "${components[@]}"; do
        if [[ ${in_degree["$component"]} -eq 0 ]]; then
            queue+=("$component")
        fi
    done

    # Process queue
    while [[ ${#queue[@]} -gt 0 ]]; do
        # Remove first element from queue
        local current="${queue[0]}"
        queue=("${queue[@]:1}")

        # Add to result
        result+=("$current")

        # Process all components that depend on current
        local dependents="${graph["$current"]}"
        if [[ -n "$dependents" ]]; then
            for dependent in $dependents; do
                # Decrease in-degree
                in_degree["$dependent"]=$((in_degree["$dependent"] - 1))

                # If in-degree becomes 0, add to queue
                if [[ ${in_degree["$dependent"]} -eq 0 ]]; then
                    queue+=("$dependent")
                fi
            done
        fi
    done

    # Check for cycles
    if [[ ${#result[@]} -ne ${#components[@]} ]]; then
        log_error "Circular dependency detected in components"

        # Find remaining components with non-zero in-degree
        local remaining=()
        for component in "${components[@]}"; do
            if [[ ${in_degree["$component"]} -gt 0 ]]; then
                remaining+=("$component")
            fi
        done

        log_error "Components involved in circular dependency: ${remaining[*]:-}"
        return 1
    fi

    # Output sorted components
    printf '%s\n' "${result[@]}"
}

# Get all dependencies (recursive) for a component
get_all_dependencies() {
    local component="$1"

    # Use a simple iterative approach instead of complex recursion
    local -A all_deps=()
    local -A visited=()
    local queue=("$component")

    while [[ ${#queue[@]} -gt 0 ]]; do
        local current="${queue[0]}"
        queue=("${queue[@]:1}")

        # Skip if already visited
        if [[ -n "${visited["$current"]:-}" ]]; then
            continue
        fi
        visited["$current"]=1

        # Get direct dependencies
        local deps
        mapfile -t deps < <(registry_requires "$current")

        for dep in "${deps[@]}"; do
            [[ -n "$dep" ]] || continue

            if [[ ! -d "$COMPONENTS_DIR/$dep" ]]; then
                log_error "Component '$current' depends on '$dep' which does not exist"
                return 1
            fi

            # Add to results (but not the original component)
            if [[ "$dep" != "$component" ]]; then
                all_deps["$dep"]=1
            fi

            # Add to queue for further processing
            queue+=("$dep")
        done
    done

    # Output all dependencies
    for dep in "${!all_deps[@]}"; do
        echo "$dep"
    done
}

# Check if components can be installed in parallel
can_install_in_parallel() {
    local component1="$1"
    local component2="$2"

    # Check if either component depends on the other
    local deps1
    mapfile -t deps1 < <(get_all_dependencies "$component1")

    local deps2
    mapfile -t deps2 < <(get_all_dependencies "$component2")

    # Check if component1 depends on component2
    for dep in "${deps1[@]}"; do
        if [[ "$dep" == "$component2" ]]; then
            return 1  # Cannot install in parallel
        fi
    done

    # Check if component2 depends on component1
    for dep in "${deps2[@]}"; do
        if [[ "$dep" == "$component1" ]]; then
            return 1  # Cannot install in parallel
        fi
    done

    # Check if both components are marked as parallel-safe
    if ! registry_parallel_safe "$component1" || ! registry_parallel_safe "$component2"; then
        return 1  # Cannot install in parallel
    fi

    # Check for resource conflicts (same package manager, etc.)
    if _have_resource_conflicts "$component1" "$component2"; then
        return 1  # Cannot install in parallel
    fi

    return 0  # Can install in parallel
}

# Check for resource conflicts between components
_have_resource_conflicts() {
    local component1="$1"
    local component2="$2"

    # For now, we'll be conservative and assume any two components
    # that use the system package manager might conflict
    # This could be enhanced to be more specific

    # If both components require sudo or system-level changes,
    # they might conflict
    if [[ -f "$COMPONENTS_DIR/$component1/install.sh" && -f "$COMPONENTS_DIR/$component2/install.sh" ]]; then
        local uses_sudo1 uses_sudo2
        uses_sudo1=$(grep -c "sudo" "$COMPONENTS_DIR/$component1/install.sh" || echo "0")
        uses_sudo2=$(grep -c "sudo" "$COMPONENTS_DIR/$component2/install.sh" || echo "0")

        if [[ "$uses_sudo1" -gt 0 && "$uses_sudo2" -gt 0 ]]; then
            return 0  # Have conflicts
        fi
    fi

    return 1  # No conflicts detected
}

# Generate parallel installation batches
generate_parallel_batches() {
    local components=("$@")
    local sorted_components
    local -A batch_assignments=()
    local batch_count=0

    # First, get topologically sorted order
    mapfile -t sorted_components < <(topological_sort "${components[@]}")

    if [[ ${#sorted_components[@]} -eq 0 ]]; then
        log_error "Failed to sort components"
        return 1
    fi

    log_debug "Generating parallel batches for ${#sorted_components[@]} components"

    # Assign components to batches
    for component in "${sorted_components[@]}"; do
        local assigned_batch=-1

        # Try to find an existing batch where this component can be installed
        for ((batch=0; batch<batch_count; batch++)); do
            local can_add_to_batch=true

            # Check if this component can be installed in parallel with all components in this batch
            for other_component in "${sorted_components[@]}"; do
                if [[ "${batch_assignments["$other_component"]:-}" == "$batch" ]]; then
                    if ! can_install_in_parallel "$component" "$other_component"; then
                        can_add_to_batch=false
                        break
                    fi
                fi
            done

            if [[ "$can_add_to_batch" == true ]]; then
                assigned_batch=$batch
                break
            fi
        done

        # If no suitable batch found, create a new one
        if [[ $assigned_batch -eq -1 ]]; then
            assigned_batch=$batch_count
            ((batch_count++))
        fi

        batch_assignments["$component"]=$assigned_batch
    done

    # Output batches
    for ((batch=0; batch<batch_count; batch++)); do
        local batch_components=()
        for component in "${sorted_components[@]}"; do
            if [[ "${batch_assignments["$component"]}" == "$batch" ]]; then
                batch_components+=("$component")
            fi
        done

        echo "BATCH_$batch:${batch_components[*]:-}"
    done
}

# Validate dependency graph for cycles and missing dependencies
validate_dependency_graph() {
    local components=("$@")
    local errors=0

    # If no components specified, validate all
    if [[ ${#components[@]} -eq 0 ]]; then
        mapfile -t components < <(registry_list_components)
    fi

    log_info "Validating dependency graph for ${#components[@]} components"

    # Check for missing dependencies
    for component in "${components[@]}"; do
        local deps
        mapfile -t deps < <(registry_requires "$component")

        for dep in "${deps[@]}"; do
            [[ -n "$dep" ]] || continue

            if [[ ! -d "$COMPONENTS_DIR/$dep" ]]; then
                log_error "Component '$component' depends on missing component '$dep'"
                ((errors++))
            fi
        done
    done

    # Test topological sort to detect cycles
    if ! topological_sort "${components[@]}" >/dev/null 2>&1; then
        log_error "Circular dependencies detected in component graph"
        ((errors++))
    fi

    if [[ $errors -eq 0 ]]; then
        log_info "Dependency graph validation passed"
        return 0
    else
        log_error "Dependency graph validation failed with $errors errors"
        return 1
    fi
}
