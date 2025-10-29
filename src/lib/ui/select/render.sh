#!/usr/bin/env bash
# select/render.sh - Rendering helpers for ui_select

_select_calc_bounds() {
  local bounds start end
  bounds="$(ui_page_bounds "$PAGE" "$PAGE_SIZE" ${#FILTERED[@]})"
  start="${bounds%% *}"
  end="${bounds##* }"
  [[ ! $start =~ ^[0-9]+$ ]] && start=0
  [[ ! $end =~ ^[0-9]+$ ]] && end=0
  START_IDX=$start
  END_IDX=$end
}
_select_recompute_page_size() {
  # Safe fallbacks (avoid unbound vars under set -u). Single-select simpler header/footer assumptions.
  local footer_lines header_base header_paged min_rows
  footer_lines=$(ui_footer_lines 0)             # Use multi footer for consistency of available space
  header_base=2                                 # base header lines (prompt + blank)
  header_paged=4                                # header when pagination info present
  min_rows="${UI_ENV_MIN_ROWS:-${UI_MIN_DEFAULT_ROWS:-3}}"
  PAGE_SIZE=$(ui_recompute_page_size ${#FILTERED[@]} "$footer_lines" "$header_base" "$header_paged" "$min_rows")
  # Ensure very small option sets fit entirely (<=2)
  if (( ${#FILTERED[@]} <= 2 )); then
    PAGE_SIZE=${#FILTERED[@]}
  fi
  TOTAL_PAGES=$(ui_pages_total ${#FILTERED[@]} "$PAGE_SIZE")
  PAGE=$(ui_page_clamp "$PAGE" "$PAGE_SIZE" ${#FILTERED[@]})
  _select_calc_bounds
  local page_items=$((END_IDX - START_IDX)); ((page_items>0)) || page_items=1
  ((CURSOR >= page_items)) && CURSOR=$((page_items-1))
}
_select_header_lines() { local base=2; [[ ${#FILTERED[@]} -gt $PAGE_SIZE ]] && base=$((base+2)); echo "$base"; }
_select_format_option() {
  # Safely render an option line. Guard against missing positional params when set -u is active.
  local list_idx="${1:-}" display="${2:-0}" opt_index is_cursor=0
  # If caller forgot to pass index, just skip rendering to avoid unbound variable errors.
  [[ -z "$list_idx" ]] && return 0
  # Bounds check: ensure index exists within FILTERED array
  if (( list_idx < 0 || list_idx >= ${#FILTERED[@]} )); then
    return 0
  fi
  opt_index="${FILTERED[$list_idx]}"
  [[ $display -eq $CURSOR ]] && is_cursor=1
  printf "%s%s" "$(ui_option_prefix "$is_cursor")" "${OPTIONS[$opt_index]}" >&2
}
_select_render_header() {
  local offset=${UI_FIXED_HEADER_COUNT:-0} spacer=${UI_FIXED_HEADER_SPACER:-0} top=${UI_FIXED_HEADER_TOP_PAD:-0}
  local start_line=$((offset+spacer+top+1))
  ui_move "$start_line" 1; msg_with_icon "🔧" "$C_PURPLE" "$PROMPT"; msg_blank
  [[ ${#FILTERED[@]} -gt $PAGE_SIZE ]] && ui_render_page_info "$PAGE" "$TOTAL_PAGES" "$START_IDX" "$END_IDX" ${#FILTERED[@]} && msg_blank
}
_select_render_options() {
  local display=0 li
  for ((li=START_IDX; li<END_IDX; li++)); do _select_format_option "$li" "$display"; printf "\n" >&2; ((display++)); done
  [[ ${#FILTERED[@]} -eq 0 ]] && msg_blank && msg_dim "No matches found"
}
_select_render_footer() {
  msg_blank
  msg_print "${C_DIM}To navigate : ${C_RESET}↑ k  ${C_DIM}|${C_RESET}  ↓ j"; [[ ${#FILTERED[@]} -gt $PAGE_SIZE ]] && msg_print "  → l  ${C_DIM}|${C_RESET}  ← h"; printf "\n" >&2
  msg_print "${C_DIM}To confirm  : ${C_RESET}⏎ Enter"; printf "\n" >&2
  msg_print "${C_DIM}To exit     : ${C_RESET}⎋ Esc"; msg_blank
}
_select_full_render() {
  _select_recompute_page_size; ui_clear_content_area; _select_calc_bounds; _select_render_header
  local base=$(_select_header_lines) offset=${UI_FIXED_HEADER_COUNT:-0} spacer=${UI_FIXED_HEADER_SPACER:-0} top=${UI_FIXED_HEADER_TOP_PAD:-0}
  HEADER_LINES=$((offset+spacer+top+base)); _select_render_options; _select_render_footer
  PAGE_ITEMS=$((END_IDX-START_IDX)); FOOTER_START=$((HEADER_LINES + PAGE_ITEMS + 1))
}
_select_redraw_page_info() {
  [[ ${#FILTERED[@]} -le $PAGE_SIZE ]] && return 0
  local base=2 offset=${UI_FIXED_HEADER_COUNT:-0} spacer=${UI_FIXED_HEADER_SPACER:-0} top=${UI_FIXED_HEADER_TOP_PAD:-0} header_lines=$((offset+spacer+top+base)) row=$((header_lines+1))
  ui_move "$row" 1; ui_clear_line; ui_render_page_info "$PAGE" "$TOTAL_PAGES" "$START_IDX" "$END_IDX" ${#FILTERED[@]}; ui_move $((row+1)) 1; ui_clear_line; msg_blank
}
_select_redraw_option_line() {
  local display="$1" opt_row; [[ ${#FILTERED[@]} -eq 0 ]] && return 0; [[ -n "$PAGE_ITEMS" && $display -ge $PAGE_ITEMS ]] && return 0
  opt_row=$((HEADER_LINES + display + 1)); [[ -n "$FOOTER_START" && $opt_row -ge $FOOTER_START ]] && return 0
  ui_move "$opt_row" 1; ui_clear_line; _select_format_option $((START_IDX + display)) "$display"; printf "\n" >&2
}
