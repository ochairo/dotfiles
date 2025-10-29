#!/usr/bin/env bash
# register/paths.sh - Path utilities
components_meta_path() { echo "$COMPONENTS_DIR/$1/component.yml"; }
components_exists() { local name="$1"; [[ -f "$(components_meta_path "$name")" ]]; }
