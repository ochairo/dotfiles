#!/usr/bin/env bash
# usage: dot component list | rebuild <name> [--force] [--no-deps]
# summary: Component operations (list, rebuild)
# group: core

set -euo pipefail


# All modules loaded by bin/dot validation registry

ACTION="$1" || ACTION="list"
[[ $# -gt 0 ]] && shift || true

case "$ACTION" in
        list)
                msg_info "Available components:";
                registry_list_components | while read -r component; do printf '  %s\n' "$component"; done
                exit 0 ;;
    rebuild)
        COMPONENT_TARGET="$1" || true
    [[ -z ${COMPONENT_TARGET:-} ]] && { msg_error "Usage: dot component rebuild <name> [--force] [--no-deps]"; exit 1; }
        shift || true
        FORCE=0 NODEPS=0
        while [[ $# -gt 0 ]]; do
            case $1 in
                --force) FORCE=1; shift ;;
                --no-deps) NODEPS=1; shift ;;
                --help|-h)
                    echo "Usage: dot component rebuild <name> [--force] [--no-deps]"
                    exit 0 ;;
                *) msg_error "Unknown flag $1"; exit 1 ;;
            esac
        done
        if [[ ! -d "$COMPONENTS_DIR/$COMPONENT_TARGET" ]]; then
            msg_error "Component not found: $COMPONENT_TARGET"; exit 1
        fi
        # Resolve dependency chain unless --no-deps
        if [[ $NODEPS == 1 ]]; then
            chain=("$COMPONENT_TARGET")
        else
            # Build minimal set: target + its dependencies via resolver
            mapfile -t ordered < <(deps_install_order "$COMPONENT_TARGET")
            chain=("${ordered[@]}")
        fi
    msg_info "Rebuild chain: ${chain[*]} (force=$FORCE deps=$((1-NODEPS)))"
        # Iterate chain
            for comp in "${chain[@]}"; do
                hc=$(registry_health_check "$comp" || true)
                # Pre-check health only if FORCE=0 and health check exists
                if [[ $FORCE == 0 && -n ${hc// /} ]]; then
                    if bash -c "$hc" >/dev/null 2>&1; then
                        msg_dim "Skip (healthy): $comp"
                        continue
                    fi
                fi
            msg_info "Reinstalling: $comp"
            if ! install_component "$comp"; then
                msg_error "Failed reinstall: $comp"
                if registry_is_critical "$comp"; then msg_error "Critical failure aborting"; exit 2; fi
            fi
            # Post health re-check
            if [[ -n ${hc// /} ]]; then
                if bash -c "$hc" >/dev/null 2>&1; then
                    msg_success "Health OK after rebuild: $comp"
                else
                    msg_warn "Health still failing after rebuild: $comp"
                fi
            fi
        done
        # Mini doctor subset (JSON disabled here; user should call full doctor if needed)
    msg_success "Rebuild complete"
        exit 0 ;;
    -h|--help|help)
        grep '^# usage:' "$0" | sed 's/^# //' ; exit 0 ;;
            *)
                    msg_error "Unknown component action: $ACTION"
                    exit 1 ;;
esac
