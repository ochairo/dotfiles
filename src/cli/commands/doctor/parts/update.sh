#!/usr/bin/env bash
# doctor/parts/update.sh - Git update state collection

doctor_git_update_state() {
  UPDATE_STATE="unknown" CURRENT_REF="" REMOTE_REF="" BRANCH="main"
  if [[ -d "$PROJECT_ROOT/.git" ]]; then
    CURRENT_REF=$(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || true)
    BRANCH=$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)
    timeout 5s git -C "$PROJECT_ROOT" fetch --quiet origin "$BRANCH" 2>/dev/null || true
    REMOTE_REF=$(git -C "$PROJECT_ROOT" rev-parse --short "origin/$BRANCH" 2>/dev/null || true)
    if [[ -n $CURRENT_REF && -n $REMOTE_REF ]]; then
      if [[ $CURRENT_REF == "$REMOTE_REF" ]]; then UPDATE_STATE="up-to-date"; else UPDATE_STATE="out-of-date"; fi
    fi
  fi
}
