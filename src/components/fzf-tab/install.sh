#!/usr/bin/env bash
set -euo pipefail
REPO="https://github.com/Aloxaf/fzf-tab.git"
TARGET="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"
if [ -d "$TARGET/.git" ]; then
	git -C "$TARGET" pull --ff-only >/dev/null 2>&1 || git -C "$TARGET" fetch --all --prune
else
	rm -rf "$TARGET"
	git clone --depth 1 "$REPO" "$TARGET"
fi
