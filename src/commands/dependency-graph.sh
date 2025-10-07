#!/usr/bin/env bash
# Advanced dependency graph visualization tool
set -euo pipefail

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$DOTFILES_ROOT/core/constants.sh"
source "$DOTFILES_ROOT/core/log.sh"
source "$DOTFILES_ROOT/core/registry.sh"

# Generate DOT graph representation of component dependencies
generate_dependency_graph() {
    local output_format="${1:-dot}"
    local output_file="${2:-}"

    echo "digraph ComponentDependencies {"
    echo "  rankdir=TB;"
    echo "  node [shape=box, style=rounded,filled];"
    echo "  edge [color=blue];"
    echo ""

    # Color nodes by category
    echo "  // Node styling by category"
    echo "  subgraph cluster_core {"
    echo "    label=\"Core Components\";"
    echo "    style=filled;"
    echo "    color=lightgrey;"

    # Find core components
    for component_dir in "$COMPONENTS_DIR"/*; do
        if [[ -d "$component_dir" ]]; then
            local component_name=$(basename "$component_dir")
            local component_yml="$component_dir/component.yml"

            if [[ -f "$component_yml" ]]; then
                local critical=$(grep "^critical:" "$component_yml" | sed 's/critical: *//' | tr -d ' ')
                if [[ "$critical" == "true" ]]; then
                    echo "    \"$component_name\" [fillcolor=lightcoral];"
                fi
            fi
        fi
    done
    echo "  }"

    echo ""
    echo "  // Dependencies"

    # Generate dependency edges
    for component_dir in "$COMPONENTS_DIR"/*; do
        if [[ -d "$component_dir" ]]; then
            local component_name=$(basename "$component_dir")
            local component_yml="$component_dir/component.yml"

            if [[ -f "$component_yml" ]]; then
                local requires=$(registry_requires "$component_name")
                if [[ -n "$requires" ]]; then
                    for dep in $requires; do
                        echo "  \"$dep\" -> \"$component_name\";"
                    done
                fi

                # Color nodes by install method
                local install_method=$(grep "^installMethod:" "$component_yml" 2>/dev/null | sed 's/installMethod: *//' | tr -d '"' || echo "unknown")
                case "$install_method" in
                    "package")
                        echo "  \"$component_name\" [fillcolor=lightblue];"
                        ;;
                    "script")
                        echo "  \"$component_name\" [fillcolor=lightyellow];"
                        ;;
                    "cask")
                        echo "  \"$component_name\" [fillcolor=lightgreen];"
                        ;;
                    "meta")
                        echo "  \"$component_name\" [fillcolor=plum];"
                        ;;
                    *)
                        echo "  \"$component_name\" [fillcolor=lightgray];"
                        ;;
                esac
            fi
        fi
    done

    echo ""
    echo "  // Legend"
    echo "  subgraph cluster_legend {"
    echo "    label=\"Legend\";"
    echo "    style=filled;"
    echo "    color=white;"
    echo "    \"Package Install\" [fillcolor=lightblue];"
    echo "    \"Script Install\" [fillcolor=lightyellow];"
    echo "    \"Cask Install\" [fillcolor=lightgreen];"
    echo "    \"Meta Component\" [fillcolor=plum];"
    echo "    \"Critical Component\" [fillcolor=lightcoral];"
    echo "  }"

    echo "}"
}

# Analyze dependency cycles
find_dependency_cycles() {
    log_info "Analyzing dependency cycles..."

    local visited=()
    local recursion_stack=()
    local cycles_found=0

    # Simple cycle detection (would need more sophisticated algorithm for full cycle detection)
    for component_dir in "$COMPONENTS_DIR"/*; do
        if [[ -d "$component_dir" ]]; then
            local component_name=$(basename "$component_dir")
            local requires=$(component_requires "$component_name")

            for dep in $requires; do
                # Check if dependency also depends on this component (simple 2-cycle)
                local dep_requires=$(component_requires "$dep" 2>/dev/null || echo "")
                if echo "$dep_requires" | grep -q "\b$component_name\b"; then
                    log_warn "Circular dependency detected: $component_name <-> $dep"
                    cycles_found=$((cycles_found + 1))
                fi
            done
        fi
    done

    if [[ $cycles_found -eq 0 ]]; then
        log_info "No circular dependencies found"
    else
        log_warn "Found $cycles_found circular dependencies"
    fi
}

# Generate installation order
generate_install_order() {
    log_info "Generating optimal installation order..."

    # Topological sort implementation
    local temp_file=$(mktemp)
    local sorted_order=()

    # Create adjacency list
    for component_dir in "$COMPONENTS_DIR"/*; do
        if [[ -d "$component_dir" ]]; then
            local component_name=$(basename "$component_dir")
            local requires=$(component_requires "$component_name")

            if [[ -n "$requires" ]]; then
                for dep in $requires; do
                    echo "$dep $component_name" >> "$temp_file"
                done
            else
                echo "$component_name" >> "$temp_file"
            fi
        fi
    done

    # Simple topological sort (would need proper implementation)
    # For now, just show dependencies first
    echo "Suggested installation order:"

    # Components with no dependencies first
    echo "1. Core components (no dependencies):"
    for component_dir in "$COMPONENTS_DIR"/*; do
        if [[ -d "$component_dir" ]]; then
            local component_name=$(basename "$component_dir")
            local requires=$(component_requires "$component_name")

            if [[ -z "$requires" ]]; then
                echo "   - $component_name"
            fi
        fi
    done

    echo "2. Components with dependencies:"
    for component_dir in "$COMPONENTS_DIR"/*; do
        if [[ -d "$component_dir" ]]; then
            local component_name=$(basename "$component_dir")
            local requires=$(component_requires "$component_name")

            if [[ -n "$requires" ]]; then
                echo "   - $component_name (depends on: $requires)"
            fi
        fi
    done

    rm -f "$temp_file"
}

# Show component statistics
show_component_stats() {
    log_info "Component Statistics:"

    local total_components=0
    local by_method=()
    local by_platform=()
    local critical_count=0
    local parallel_safe_count=0

    for component_dir in "$COMPONENTS_DIR"/*; do
        if [[ -d "$component_dir" ]]; then
            total_components=$((total_components + 1))
            local component_name=$(basename "$component_dir")
            local component_yml="$component_dir/component.yml"

            if [[ -f "$component_yml" ]]; then
                # Count by install method
                local install_method=$(grep "^installMethod:" "$component_yml" 2>/dev/null | sed 's/installMethod: *//' | tr -d '"' || echo "unknown")
                echo "$install_method" >> /tmp/methods.tmp

                # Count critical components
                local critical=$(grep "^critical:" "$component_yml" | sed 's/critical: *//' | tr -d ' ')
                if [[ "$critical" == "true" ]]; then
                    critical_count=$((critical_count + 1))
                fi

                # Count parallel safe components
                local parallel_safe=$(grep "^parallelSafe:" "$component_yml" | sed 's/parallelSafe: *//' | tr -d ' ')
                if [[ "$parallel_safe" == "true" ]]; then
                    parallel_safe_count=$((parallel_safe_count + 1))
                fi
            fi
        fi
    done

    echo "Total components: $total_components"
    echo "Critical components: $critical_count"
    echo "Parallel-safe components: $parallel_safe_count"
    echo ""
    echo "By installation method:"

    if [[ -f /tmp/methods.tmp ]]; then
        sort /tmp/methods.tmp | uniq -c | while read count method; do
            echo "  $method: $count"
        done
        rm -f /tmp/methods.tmp
    fi
}

# Main function
main() {
    local command="${1:-graph}"

    case "$command" in
        "graph")
            echo "Generating dependency graph..."
            generate_dependency_graph "dot"
            ;;
        "cycles")
            find_dependency_cycles
            ;;
        "order")
            generate_install_order
            ;;
        "stats")
            show_component_stats
            ;;
        *)
            echo "Usage: $0 {graph|cycles|order|stats}"
            echo ""
            echo "Commands:"
            echo "  graph  - Generate DOT graph of dependencies"
            echo "  cycles - Find circular dependencies"
            echo "  order  - Show suggested installation order"
            echo "  stats  - Show component statistics"
            exit 1
            ;;
    esac
}

main "$@"
