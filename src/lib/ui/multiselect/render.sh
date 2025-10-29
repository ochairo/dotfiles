#!/usr/bin/env bash
# multiselect/render.sh - rendering helpers for multi-select UI

[[ -n "${UI_MULTISELECT_RENDER_LOADED:-}" ]] && return 0
readonly UI_MULTISELECT_RENDER_LOADED=1

## Helper functions moved to multiselect/state.sh (ms_filtered_count, ms_min_content_rows, ms_compute_capacity)
## Transition: using direct ui_* component functions (footer/header/error/options); shims scheduled for removal.

# -----------------------------------------------------------------------------
# Rendering primitives
# -----------------------------------------------------------------------------
## Option formatting & list rendering provided by ui_option_format/ui_options_render.

## Footer rendering via ui_footer_render/ui_footer_lines.

## Header rendering via ui_header_render/ui_header_lines.

# -----------------------------------------------------------------------------
# Full render orchestrator (strict alternation & clearing)
# -----------------------------------------------------------------------------
ms_full_render() {
  # If a resize is pending, escalate to first-render semantics to ensure a total wipe.
  if [[ ${UI_MULTISELECT_PENDING_RESIZE:-0} == 1 ]]; then
    UI_MULTISELECT_FIRST_RENDER=1
    UI_MULTISELECT_PENDING_RESIZE=0
    UI_MULTISELECT_NEEDS_HEADER=1
  fi
  # 1. Ensure a fixed header exists (fallback if user skipped welcome)
  if [[ "${UI_FIXED_HEADER_SET:-0}" != 1 ]]; then
    local _fh_title _fh_width
    _fh_width=$(tput cols 2>/dev/null || echo 120); ((_fh_width<40)) && _fh_width=40
    _fh_title="🔧 Dotfiles Installation Wizard"
    UI_FIXED_HEADER_LINES=("" "$_fh_title" "")
    UI_FIXED_HEADER_COUNT=3
    UI_FIXED_HEADER_SET=1
  fi
  # 2. Unified clearing strategy:
  #    ALWAYS clear dynamic content region before rendering header/options.
  #    This prevents stacked duplicate headers/lists on rapid resize or repeated full renders.
  local fixed=${UI_FIXED_HEADER_COUNT:-0} spacer=${UI_FIXED_HEADER_SPACER:-0} top=${UI_FIXED_HEADER_TOP_PAD:-0}
  local region_start=$((fixed+spacer+top+1))
  if [[ ${UI_MULTISELECT_FIRST_RENDER:-0} == 1 || ${UI_MULTISELECT_NEEDS_HEADER:-0} == 1 ]]; then
    # Full screen + header rerender for first render / forced header refresh.
    ui_clear_screen 2>/dev/null || { ui_move 1 1; printf '\033[J' >&2; }
    if [[ -t 1 ]]; then printf '\033[2J\033[H' >&1; fi
    ui_fixed_header_rerender 2>/dev/null || true
    UI_MULTISELECT_FIRST_RENDER=0
    UI_MULTISELECT_NEEDS_HEADER=0
    fixed=${UI_FIXED_HEADER_COUNT:-0}; spacer=${UI_FIXED_HEADER_SPACER:-0}; top=${UI_FIXED_HEADER_TOP_PAD:-0}
    region_start=$((fixed+spacer+top+1))
  else
    # Just clear the content area beneath the already-rendered fixed header.
    if command -v ui_clear_content_area >/dev/null 2>&1; then
      ui_clear_content_area
    else
      ui_move "$region_start" 1; printf '\033[J' >&2
    fi
  fi

  # 3. Capacity + adopt dynamic page_size BEFORE computing header lines
  local min metrics capacity need_paging rows footer base_header filtered_total header_lines_normal
  min=$(ms_min_content_rows)
  metrics=$(ms_compute_capacity)
  read capacity need_paging rows fixed spacer top footer base_header < <(ui_layout_parse_metrics "$metrics")
  filtered_total=$(ms_filtered_count)
  if (( filtered_total >= 5 && capacity < 5 )); then capacity=5; fi
  if (( capacity > 10 )); then capacity=10; fi
  # Adopt capacity as page_size first (pagination depends on it)
  page_size=$capacity
  total_pages=$(ui_pages_total "$filtered_total" "$page_size")
  page=$(ui_page_clamp "$page" "$page_size" "$filtered_total")
  ms_calc_bounds
  # Now compute header lines with final page_size
  # Compact header: always single blank line after prompt for multiselect (no extra spacer lines from pagination)
  header_lines_normal=2

  # 4. Height error path
  if (( capacity < min )); then
    ui_clear_screen
    ui_fixed_header_rerender 2>/dev/null || true
    fixed=${UI_FIXED_HEADER_COUNT:-0}; spacer=${UI_FIXED_HEADER_SPACER:-0}; top=${UI_FIXED_HEADER_TOP_PAD:-0}
    region_start=$((fixed+spacer+top+1))
    ui_move "$region_start" 1; printf '\033[J' >&2
    ui_move "$region_start" 1
  ui_error_render
    UI_MULTISELECT_LAST_TOTAL_LINES=3
    return 0
  fi

  # 5. Header (render with finalized pagination/window metrics)
  # Region already cleared; just render compact header.
  ui_move "$region_start" 1
  ui_header_render_compact "${prompt}"  # compact header: prompt + single blank line
  local option_start_line=$((region_start + header_lines_normal))
  # Register blocks (Phase 1). Header block height = header_lines_normal.
  if command -v ui_block_register >/dev/null 2>&1; then
    ui_block_register header "$region_start" "$header_lines_normal"
  fi
  AM_REGION_START=$region_start
  AM_OPTION_START=$option_start_line

  # 6. Filter bar
  local filter_row=0
  # Clamp cursor within new visible range (after adopting capacity)
  local _page_items=$((end_idx - start_idx))
  if (( _page_items > 0 && cursor >= _page_items )); then cursor=$((_page_items - 1)); fi
  if [[ ${filter_mode:-0} -eq 1 ]]; then
    ui_move "$option_start_line" 1
    msg_with_icon "${UI_ICON_FILTER:-⌕}" "$C_CYAN" "Filter (live): ${filter}"
    msg_blank
    filter_row=$option_start_line
    option_start_line=$((option_start_line + 2))
  fi

  # 7. Options
  ui_move "$option_start_line" 1
  AM_HEADER_LINES=$((fixed+spacer+top+header_lines_normal))
  ui_options_render
  local page_items=$((end_idx - start_idx))
  # Register/resize content block (options region)
  if command -v ui_block_register >/dev/null 2>&1; then
    local content_height=$page_items
    (( content_height < 0 )) && content_height=0
    ui_block_register content "$option_start_line" "$content_height"
  fi

  # 8. Footer
  ui_footer_render "${filter_mode:-0}" "${page_size:-0}"
  AM_PAGE_ITEMS=$page_items
  AM_FOOTER_START=$((AM_HEADER_LINES + AM_PAGE_ITEMS + 1))
  # Footer block registration
  if command -v ui_block_register >/dev/null 2>&1; then
    local footer_start=$AM_FOOTER_START
    local footer_height=$(ui_footer_lines "${filter_mode:-0}")
    ui_block_register footer "$footer_start" "$footer_height"
  fi

  # 9. Cursor reposition (filter mode)
  if [[ ${filter_mode:-0} -eq 1 && $filter_row -ge $region_start ]]; then
    ms_filter_cursor_place "$filter_row"
  fi

  # 10. Track dynamic lines
  UI_MULTISELECT_LAST_TOTAL_LINES=$((header_lines_normal + page_items + $(ui_footer_lines "${filter_mode:-0}")))
}

# Misc helpers
## Resize handler moved to multiselect/handlers.sh

ms_redraw_option_line() {
  local display_index="$1" opt_row
  [[ "$(ms_filtered_count)" -eq 0 ]] && return 0
  [[ -n "${AM_PAGE_ITEMS:-}" && $display_index -ge ${AM_PAGE_ITEMS} ]] && return 0
  # Use stored option start line to avoid drift when header height or clearing strategy changes.
  local start_line=${AM_OPTION_START:-$((AM_HEADER_LINES + 1))}
  opt_row=$((start_line + display_index))
  [[ -n "${AM_FOOTER_START:-}" && $opt_row -ge ${AM_FOOTER_START} ]] && return 0
  ui_move "$opt_row" 1
  ui_clear_line
  ui_option_format $((start_idx + display_index)) "$display_index"
  printf "\n" >&2
}
