#!/usr/bin/env bash
# term/detect.sh - capability detection

term_detect() {
  if [[ ${COLORTERM:-} == *truecolor* || ${COLORTERM:-} == *24bit* ]] || grep -qi 'truecolor\|24bit' <<<"${TERM:-}"; then TERM_TRUECOLOR=1 TERM_256COLOR=1; elif command -v tput >/dev/null 2>&1; then local colors; colors=$(tput colors 2>/dev/null || echo 0); [[ $colors -ge 256 ]] && TERM_256COLOR=1; fi
  case "${OSTYPE:-}" in darwin*) TERM_EMOJI=1 ;; linux*) [[ -n ${DISPLAY:-} || -n ${WAYLAND_DISPLAY:-} ]] && TERM_EMOJI=1 ;; esac
  [[ ${DOTFILES_NO_EMOJI:-0} == 1 || ${NO_EMOJI:-0} == 1 ]] && TERM_EMOJI=0
  [[ -t 0 && -t 1 ]] && TERM_INTERACTIVE=1
  export TERM_TRUECOLOR TERM_256COLOR TERM_EMOJI TERM_INTERACTIVE
}
term_detect
