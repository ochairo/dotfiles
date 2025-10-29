#!/usr/bin/env bash
# select/eventloop.sh - ui_select main function (event loop)

ui_select() {
  [[ $# -lt 2 ]] && msg_error "ui_select requires prompt and at least one option" && return 1
  PROMPT="$1"; shift; OPTIONS=("$@")
  if [[ ${#OPTIONS[@]} -eq 0 ]]; then msg_warn "No options provided"; return 1; fi
  FILTERED=(); CURSOR=0; FILTER=""; PAGE=0; PAGE_SIZE=10; TOTAL_PAGES=0; START_IDX=0; END_IDX=0; HEADER_LINES=0; PAGE_ITEMS=0; FOOTER_START=0
  local i; for ((i=0;i<${#OPTIONS[@]};i++)); do FILTERED+=("$i"); done
  ui_session_begin _select_full_render  # session module performs initial render
  _select_calc_bounds
  while true; do
    local key prev_cursor prev_page full_redraw page_items actual_idx new_filter k1 k2 display_count header_lines opt_row
    IFS= read -rsn1 key
    prev_cursor=$CURSOR; prev_page=$PAGE; full_redraw=0
    case "$key" in
      $'\x1b') if read -rsn1 -t 0.2 k1 && [[ $k1 == '[' ]] && read -rsn1 -t 0.2 k2; then
                  case "$k2" in
                    A) if [[ $CURSOR -gt 0 ]]; then ((CURSOR--)); elif [[ $PAGE -gt 0 ]]; then ((PAGE--)); CURSOR=$((PAGE_SIZE-1)); full_redraw=2; fi ;;
                    B) page_items=$((END_IDX-START_IDX)); if [[ $CURSOR -lt $((page_items-1)) ]]; then ((CURSOR++)); elif [[ $((PAGE+1)) -lt $TOTAL_PAGES ]]; then ((PAGE++)); CURSOR=0; full_redraw=2; fi ;;
                    C) if [[ $((PAGE+1)) -lt $TOTAL_PAGES ]]; then ((PAGE++)); CURSOR=0; full_redraw=2; fi ;;
                    D) if [[ $PAGE -gt 0 ]]; then ((PAGE--)); CURSOR=0; full_redraw=2; fi ;;
                  esac; continue; fi; ui_session_end; return 1 ;;
      k) if [[ $CURSOR -gt 0 ]]; then ((CURSOR--)); elif [[ $PAGE -gt 0 ]]; then ((PAGE--)); CURSOR=$((PAGE_SIZE-1)); full_redraw=2; fi ;;
      j) page_items=$((END_IDX-START_IDX)); if [[ $CURSOR -lt $((page_items-1)) ]]; then ((CURSOR++)); elif [[ $((PAGE+1)) -lt $TOTAL_PAGES ]]; then ((PAGE++)); CURSOR=0; full_redraw=2; fi ;;
      l) if [[ $((PAGE+1)) -lt $TOTAL_PAGES ]]; then ((PAGE++)); CURSOR=0; full_redraw=2; fi ;;
      h) if [[ $PAGE -gt 0 ]]; then ((PAGE--)); CURSOR=0; full_redraw=2; fi ;;
  /) continue ;;
      q) ui_session_end; return 1 ;;
      '') ui_session_end; if [[ ${#FILTERED[@]} -gt 0 ]]; then actual_idx="${FILTERED[$((START_IDX+CURSOR))]}"; echo "${OPTIONS[$actual_idx]}"; return 0; else return 1; fi ;;
    esac
    _select_calc_bounds
    if [[ $full_redraw -eq 1 ]]; then _select_full_render; continue; fi
    if [[ $full_redraw -eq 2 || $PAGE -ne $prev_page ]]; then
      _select_redraw_page_info; display_count=0; header_lines=$HEADER_LINES
      for ((li=START_IDX; li<END_IDX; li++)); do opt_row=$((header_lines + display_count + 1)); printf "\033[%d;1H\033[2K" "$opt_row" >&2; _select_format_option "$li" "$display_count"; printf "\n" >&2; ((display_count++)); done
      PAGE_ITEMS=$display_count; FOOTER_START=$((HEADER_LINES + PAGE_ITEMS + 1)); continue
    fi
    if [[ $CURSOR -ne $prev_cursor ]]; then _select_redraw_option_line "$prev_cursor"; _select_redraw_option_line "$CURSOR"; fi
  done
}
