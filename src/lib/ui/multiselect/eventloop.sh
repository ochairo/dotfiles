#!/usr/bin/env bash
# multiselect/eventloop.sh - main ui_multiselect function & keyboard handling

[[ -n "${UI_MULTISELECT_EVENT_LOADED:-}" ]] && return 0
readonly UI_MULTISELECT_EVENT_LOADED=1

ui_multiselect() {
  [[ $# -lt 2 ]] && msg_error "ui_multiselect requires at least 2 arguments" && return 1
  ms_init_state "$@" || return 1
  # Ensure fixed header re-renders on first multiselect screen
  UI_MULTISELECT_NEEDS_HEADER=1
  # Mark first render so renderer performs a full screen clear (remove prior select screen remnants)
  UI_MULTISELECT_FIRST_RENDER=1
  # If a fixed header hasn't been set (e.g. user skipped welcome), create a default wizard header.
  if [[ "${UI_FIXED_HEADER_SET:-0}" != 1 ]]; then
    local title width
    width=$(tput cols 2>/dev/null || echo 120); (( width < 40 )) && width=40
    title="🔧 Dotfiles Installation Wizard"
    # Use same pattern as welcome: placeholder array then rerender centers second line.
    UI_FIXED_HEADER_LINES=("" "$title" "")
    UI_FIXED_HEADER_COUNT=3
    UI_FIXED_HEADER_SET=1
  fi
  # Begin session (session module performs initial render automatically)
  ui_session_begin ms_full_render
  # Override SIGWINCH trap with lightweight flag setter (avoid double render & race)
  trap 'ms_handle_resize' SIGWINCH
  # REMOVE duplicate initial ms_full_render call (was causing doubled header/content)
  local key prev_cursor prev_page redraw_full k1 k2 page_items actual_idx new_filter display_count header_lines opt_row idx
  local key key_timeout
  key_timeout="${DOTFILES_UI_KEY_TIMEOUT:-0.2}"
  while true; do
    # Handle pending resize before blocking on input
    if [[ "${UI_MULTISELECT_PENDING_RESIZE:-0}" == 1 ]]; then
      UI_MULTISELECT_PENDING_RESIZE=0
      ms_full_render
    fi
    IFS= read -rsn1 -t "$key_timeout" key || key="__NO_INPUT__"
    if [[ "$key" == "__NO_INPUT__" ]]; then
      continue
    fi
    # Incremental filter mode handling
    if [[ $filter_mode -eq 1 ]]; then
      case "$key" in
        ' ') # Space toggles selection while in live filter mode
          if [[ ${#filtered_indices[@]} -gt 0 ]]; then actual_idx="${filtered_indices[$((start_idx+cursor))]}"; [[ "${selected_status[$actual_idx]}" == 1 ]] && selected_status[$actual_idx]=0 || selected_status[$actual_idx]=1; ms_full_render; ui_show_cursor 2>/dev/null || true; fi
          continue
          ;;
        $'\n'|$'\r') # ENTER finish editing (keep filter)
          filter_mode=0
          ui_hide_cursor 2>/dev/null || true
          ms_recompute_page_metrics
          ms_full_render
          continue
          ;;
        $'\x1b') # ESC clears filter & exits edit mode (restores full list)
          filter=""
          ui_filter_apply "$filter" options filtered_indices
          page=0; cursor=0
          filter_mode=0
          ui_hide_cursor 2>/dev/null || true
          ms_recompute_page_metrics
          ms_full_render
          continue
          ;;
        $'\x7f') # Backspace
          if [[ -n "$filter" ]]; then
            filter="${filter%?}"
            ui_filter_apply "$filter" options filtered_indices
            page=0; cursor=0
            ms_recompute_page_metrics
            ms_full_render; ui_show_cursor 2>/dev/null || true
          fi
          continue
          ;;
        $'\x15') # Ctrl-U clear
          filter=""
          ui_filter_apply "$filter" options filtered_indices
          page=0; cursor=0
          ms_recompute_page_metrics
          ms_full_render
          continue
          ;;
        '/') # Toggle off filter mode
          filter_mode=0
          ui_hide_cursor 2>/dev/null || true
          ms_full_render
          continue
          ;;
        *)
          # Accept printable characters only
          if printf %s "$key" | LC_ALL=C grep -q '^[[:print:]]$'; then
            filter+="$key"
            ui_filter_apply "$filter" options filtered_indices
            page=0; cursor=0
            ms_recompute_page_metrics
            ms_full_render; ui_show_cursor 2>/dev/null || true
          fi
          continue
          ;;
      esac
    fi
    prev_cursor=$cursor
    prev_page=$page
    redraw_full=0
    # Secondary resize check in case resize occurred during blocking read
    if [[ "${UI_MULTISELECT_PENDING_RESIZE:-0}" == 1 ]]; then
      UI_MULTISELECT_PENDING_RESIZE=0
      ms_full_render
      continue
    fi
  case "$key" in
      $'\x1b') # Escape / arrows (always exit if not in filter_mode)
        if read -rsn1 -t 0.2 k1 && [[ $k1 == '[' ]] && read -rsn1 -t 0.2 k2; then
          case "$k2" in
            A) if [[ $cursor -gt 0 ]]; then ((cursor--)); elif [[ $page -gt 0 ]]; then ((page--)); cursor=$((page_size-1)); redraw_full=1; fi ;;
            B) page_items=$((end_idx - start_idx)); if [[ $cursor -lt $((page_items-1)) ]]; then ((cursor++)); elif [[ $((page+1)) -lt $total_pages ]]; then ((page++)); cursor=0; redraw_full=1; fi ;;
            C) if [[ $((page+1)) -lt $total_pages ]]; then ((page++)); cursor=0; redraw_full=1; fi ;;
            D) if [[ $page -gt 0 ]]; then ((page--)); cursor=0; redraw_full=1; fi ;;
          esac
          continue
        fi
        # Outside incremental filter editing, exit immediately (single ESC behavior)
        ui_session_end
        ms_cleanup_state
        return 1
        ;;
      k) if [[ $cursor -gt 0 ]]; then ((cursor--)); elif [[ $page -gt 0 ]]; then ((page--)); cursor=$((page_size-1)); redraw_full=1; fi ;;
      j) page_items=$((end_idx - start_idx)); if [[ $cursor -lt $((page_items-1)) ]]; then ((cursor++)); elif [[ $((page+1)) -lt $total_pages ]]; then ((page++)); cursor=0; redraw_full=1; fi ;;
      l) if [[ $((page+1)) -lt $total_pages ]]; then ((page++)); cursor=0; redraw_full=1; fi ;;
      h) if [[ $page -gt 0 ]]; then ((page--)); cursor=0; redraw_full=1; fi ;;
      ' ') if [[ ${#filtered_indices[@]} -gt 0 ]]; then actual_idx="${filtered_indices[$((start_idx+cursor))]}"; [[ "${selected_status[$actual_idx]}" == 1 ]] && selected_status[$actual_idx]=0 || selected_status[$actual_idx]=1; redraw_full=1; fi ;;
  /) if [[ $filter_mode -eq 0 ]]; then filter_mode=1; ui_show_cursor 2>/dev/null || true; ms_full_render; fi ;;
  b) ui_session_end; echo "__BACK__"; ms_cleanup_state; return 1 ;; # back navigation sentinel output
      '') ui_session_end; local result=""; for ((idx=0; idx<total; idx++)); do [[ "${selected_status[$idx]}" == 1 ]] && result="${result:+$result }${options[$idx]}"; done; echo "$result"; ms_cleanup_state; return 0 ;;
      *) continue ;; # Suppress all other inputs silently
    esac
    ms_calc_bounds
    if [[ $page -ne $prev_page ]]; then
      # Use full render to avoid duplicated headers/content on page changes
      ms_full_render
      continue
    fi
    if [[ $redraw_full -eq 1 ]]; then ms_full_render; continue; fi
    if [[ $cursor -ne $prev_cursor ]]; then ms_redraw_option_line "$prev_cursor"; ms_redraw_option_line "$cursor"; fi
  done
}
