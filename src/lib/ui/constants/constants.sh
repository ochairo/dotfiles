#!/usr/bin/env bash
# constants/constants.sh - Shared UI constants (Phase 2)
# Keep file <120 lines; add only stable, cross-component values.

[[ -n "${UI_CONSTANTS_LOADED:-}" ]] && return 0
readonly UI_CONSTANTS_LOADED=1

# Minimum rows default (overridden by DOTFILES_MIN_CONTENT_ROWS)
UI_MIN_DEFAULT_ROWS=3

# Icon glyphs (allow consumer override via env if desired later)
UI_ICON_CURSOR="❯"
UI_ICON_SELECTED="✓"
UI_ICON_FILTER="⌕"
UI_ICON_BACK="↩"
UI_ICON_EXIT="⎋"
UI_ICON_CHECKED="☑"
UI_ICON_UNCHECKED="☐"
UI_ICON_WRENCH="🔧"

# Help lines (multiselect normal mode)
UI_HELP_MULTISELECT_NAV_PAGED='To navigate : ↑ k  |  ↓ j  |  → l  |  ← h'
UI_HELP_MULTISELECT_NAV_SIMPLE='To navigate : ↑ k  |  ↓ j'
UI_HELP_MULTISELECT_SELECT='To select   : ␣ space (check/uncheck)'
UI_HELP_MULTISELECT_FILTER='To filter   : ⌕ /'
UI_HELP_MULTISELECT_CONFIRM='To confirm  : ⏎ enter'
UI_HELP_MULTISELECT_BACK='To go back  : ↩ b'
UI_HELP_MULTISELECT_EXIT='To exit     : ⎋ esc'

# Help lines (multiselect filter mode)
UI_HELP_FILTER_SELECT='To select     : ␣ space (check/uncheck)'
UI_HELP_FILTER_EXIT='To exit filter: ⎋ esc'

# Help lines (single select)
UI_HELP_SINGLE_FILTER='To filter   : ⌕ /'
UI_HELP_SINGLE_CONFIRM='To confirm  : ⏎ enter'
UI_HELP_SINGLE_EXIT='To exit     : ⎋ esc'

export UI_MIN_DEFAULT_ROWS \
  UI_ICON_CURSOR UI_ICON_SELECTED UI_ICON_FILTER UI_ICON_BACK UI_ICON_EXIT \
  UI_ICON_CHECKED UI_ICON_UNCHECKED UI_ICON_WRENCH \
  UI_HELP_MULTISELECT_NAV_PAGED UI_HELP_MULTISELECT_NAV_SIMPLE \
  UI_HELP_MULTISELECT_SELECT UI_HELP_MULTISELECT_FILTER UI_HELP_MULTISELECT_CONFIRM \
  UI_HELP_MULTISELECT_BACK UI_HELP_MULTISELECT_EXIT \
  UI_HELP_FILTER_SELECT UI_HELP_FILTER_EXIT \
  UI_HELP_SINGLE_FILTER UI_HELP_SINGLE_CONFIRM UI_HELP_SINGLE_EXIT
