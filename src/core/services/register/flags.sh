#!/usr/bin/env bash
# register/flags.sh - Component boolean flags
components_is_parallel_safe() { local value; value=$(components_get_field "$1" "parallelSafe"); [[ "$value" == "true"* ]]; }
components_is_critical() { local value; value=$(components_get_field "$1" "critical"); [[ "$value" == "true"* ]]; }

# Compatibility shims (legacy API names)
registry_is_critical() { components_is_critical "$1"; }
registry_is_parallel_safe() { components_is_parallel_safe "$1"; }
export -f registry_is_critical registry_is_parallel_safe
