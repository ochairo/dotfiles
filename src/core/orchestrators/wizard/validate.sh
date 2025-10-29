#!/usr/bin/env bash
# wizard/validate.sh - Selection validation

presets_validate_selection() { local selection="$1"; [[ -n $selection && $selection != ',' ]]; }
