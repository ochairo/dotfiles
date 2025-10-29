#!/usr/bin/env bash
# ui/blocks/blocks.sh - Terminal block system (header/content/footer regions)
# Goal: emulate HTML-like <div> sections with independent clear & render cycles.
# Bash 3.2 compatible (no associative arrays). All output -> stderr.
# Provides minimal API (Phase 1):
#   ui_blocks_init
#   ui_block_register <name> <start_line> <height>
#   ui_block_resize <name> <start_line> <height>
#   ui_block_clear <name>
#   ui_block_render <name> <renderer_fn>
#   ui_blocks_relayout <header_height> <content_height> <footer_height>
#   ui_block_exists <name>
#   ui_block_line <name>    (echo start_line)
#   ui_block_height <name>  (echo height)
#   ui_blocks_clear_content
#
# Design:
#   We avoid associative arrays; store metadata in variables:
#     BLOCK_<NAME>_START, BLOCK_<NAME>_HEIGHT
#   Names tracked in BLOCK_REGISTRY (space-delimited).
#   Clearing a block clears only its lines (not entire screen) by iterating.
#   Rendering uses provided renderer function (must write to stderr, not move cursor unexpectedly).
#   Relayout recomputes content/footer start lines if header height changes.
#
# Future Extensions (Phase 2+):
#   - Diff-based redraw (track previous rendered lines in temp file or array)
#   - Overlapping block detection & prevention
#   - Scrollable content block with virtual viewport
#   - Focusable interactive components registry (buttons, inputs)
#   - Event hooks: before_render/after_render per block
#
# Safety: All functions tolerate missing blocks; clearing/rendering non-existent block is a no-op.

[[ -n "${UI_BLOCKS_MODULE_LOADED:-}" ]] && return 0
readonly UI_BLOCKS_MODULE_LOADED=1

ui_blocks_init() {
  BLOCK_REGISTRY=""
}

ui_block_exists() {
  local name="$1"
  [[ -n "${name}" && -n "${BLOCK_REGISTRY}" ]] || { return 1; }
  for b in $BLOCK_REGISTRY; do
    [[ "$b" == "$name" ]] && return 0
  done
  return 1
}

ui_block_register() {
  local name="$1" start="$2" height="$3"
  [[ -z "$name" || -z "$start" || -z "$height" ]] && return 1
  [[ ! "$start" =~ ^[0-9]+$ || ! "$height" =~ ^[0-9]+$ ]] && return 1
  if ! ui_block_exists "$name"; then
    BLOCK_REGISTRY="${BLOCK_REGISTRY:+$BLOCK_REGISTRY }$name"
  fi
  eval "BLOCK_${name}_START=$start"
  eval "BLOCK_${name}_HEIGHT=$height"
}

ui_block_line() {
  local name="$1"; eval "echo \${BLOCK_${name}_START:-}" 2>/dev/null || true
}

ui_block_height() {
  local name="$1"; eval "echo \${BLOCK_${name}_HEIGHT:-}" 2>/dev/null || true
}

ui_block_resize() {
  local name="$1" start="$2" height="$3"
  [[ -z "$name" ]] && return 1
  [[ ! "$start" =~ ^[0-9]+$ || ! "$height" =~ ^[0-9]+$ ]] && return 1
  ui_block_register "$name" "$start" "$height"  # reuses logic
}

ui_block_clear() {
  local name="$1" start height
  start=$(ui_block_line "$name")
  height=$(ui_block_height "$name")
  [[ -z "$start" || -z "$height" ]] && return 0
  local end=$((start + height - 1))
  local line
  for ((line=start; line<=end; line++)); do
    ui_move "$line" 1
    ui_clear_line
  done
}

ui_blocks_clear_content() {
  # Clears all blocks except header/footer (heuristic: skip names containing 'header' or 'footer').
  local name
  for name in $BLOCK_REGISTRY; do
    if [[ "$name" == *header* || "$name" == *footer* ]]; then
      continue
    fi
    ui_block_clear "$name"
  done
}

ui_block_render() {
  local name="$1" fn="$2" start height
  [[ -z "$name" || -z "$fn" ]] && return 1
  if ! declare -F "$fn" >/dev/null; then
    msg_warn "block render: function '$fn' missing"
    return 1
  fi
  start=$(ui_block_line "$name")
  height=$(ui_block_height "$name")
  [[ -z "$start" || -z "$height" ]] && return 1
  ui_block_clear "$name"
  ui_move "$start" 1
  "$fn" "$name" "$start" "$height"
}

ui_blocks_relayout() {
  # Recompute content/footer block start lines: <header> <content> <footer>
  local header_h="$1" content_h="$2" footer_h="$3"
  [[ ! "$header_h" =~ ^[0-9]+$ || ! "$content_h" =~ ^[0-9]+$ || ! "$footer_h" =~ ^[0-9]+$ ]] && return 1
  local header_start=1 content_start=$((header_start + header_h)) footer_start=$((content_start + content_h))
  ui_block_resize header "$header_start" "$header_h"
  ui_block_resize content "$content_start" "$content_h"
  ui_block_resize footer "$footer_start" "$footer_h"
}

# Example minimal renderer for content (debug)
ui_block_render_example_content() {
  local name="$1" start="$2" height="$3" i
  for ((i=0;i<height;i++)); do
    printf '%s[content]%s line %d/%d\n' "$C_DIM" "$C_RESET" $((i+1)) "$height" >&2
  done
}

export -f ui_blocks_init ui_block_register ui_block_resize ui_block_clear ui_block_render ui_blocks_relayout ui_block_exists ui_block_line ui_block_height ui_blocks_clear_content ui_block_render_example_content
