#!/usr/bin/env bash
# resolver loader - sources segmented dependency resolution utilities
SOURCE_DIR="${CORE_DIR:-$DOTFILES_ROOT/src/core}/services/resolver"
for seg in init resolve cycle query parallel; do
  # shellcheck disable=SC1090
  [ -f "$SOURCE_DIR/$seg.sh" ] && source "$SOURCE_DIR/$seg.sh"
done
