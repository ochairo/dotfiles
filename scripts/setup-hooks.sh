#!/usr/bin/env bash
set -euo pipefail
# Configure git to use project-local hooks directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK_DIR="$ROOT_DIR/.githooks"

if ! command -v git >/dev/null 2>&1; then
	echo "git not found" >&2
	exit 1
fi

git config core.hooksPath "$HOOK_DIR"
chmod +x "$HOOK_DIR"/* || true

echo "Git hooks path set to $HOOK_DIR"
echo "Pre-commit hook installed. Ensure shfmt is installed: 'brew install shfmt' or 'go install mvdan.cc/sh/v3/cmd/shfmt@latest'"
