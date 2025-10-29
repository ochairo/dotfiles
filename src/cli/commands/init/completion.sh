#!/usr/bin/env bash
# init/completion.sh - Completion messaging

init_show_completion() {
  if [[ $DRY_RUN == 0 ]]; then
    presets_show_completion
  else
    msg_info "Dry-run complete (no changes applied)."
  fi
}
