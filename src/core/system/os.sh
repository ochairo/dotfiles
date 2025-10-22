#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/init/constants.sh"
