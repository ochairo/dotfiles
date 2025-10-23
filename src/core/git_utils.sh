#!/usr/bin/env bash
# git_utils.sh - Git repository status functions

# Prevent double loading
[[ -n "${DOTFILES_GIT_UTILS_LOADED:-}" ]] && return 0
readonly DOTFILES_GIT_UTILS_LOADED=1

# Git update functions
update_repo_branch() {
    git -C "$DOTFILES_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"
}

update_current_ref() {
    git -C "$DOTFILES_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown"
}

update_remote_ref() {
    git -C "$DOTFILES_ROOT" fetch origin 2>/dev/null
    git -C "$DOTFILES_ROOT" rev-parse --short origin/HEAD 2>/dev/null || echo "unknown"
}

update_state() {
    local current
    local remote
    current=$(update_current_ref)
    remote=$(update_remote_ref)

    if [[ "$current" == "$remote" ]]; then
        echo "up-to-date"
    else
        echo "out-of-date"
    fi
}

update_pull() {
    git -C "$DOTFILES_ROOT" pull origin "$(update_repo_branch)" 2>&1
}
