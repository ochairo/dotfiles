#!/usr/bin/env bash
# tests/helpers/common.sh - Shared test utilities

set -euo pipefail

assert_success() { [[ "$1" -eq 0 ]] || { echo "Expected success got $1" >&2; return 1; }; }
assert_fail() { [[ "$1" -ne 0 ]] || { echo "Expected failure got 0" >&2; return 1; }; }
assert_output_contains() { [[ "$1" == *"$2"* ]] || { echo "Missing substring '$2' in output: $1" >&2; return 1; }; }
assert_file_exists() { [[ -e "$1" ]] || { echo "File not found: $1" >&2; return 1; }; }

loader_guard_check() {
  local loader="$1" guard="$2"
  local before after
  before="$(declare -F | wc -l)"
  # shellcheck source=/dev/null
  source "$loader"
  if ! (env | grep -q "$guard" || declare -p "$guard" 2>/dev/null | grep -q "$guard"); then
    echo "Guard variable not set: $guard" >&2; return 1; fi
  # shellcheck source=/dev/null
  source "$loader"
  after="$(declare -F | wc -l)"
  [[ "$before" -le "$after" ]] || { echo "Function count decreased after reload" >&2; return 1; }
}

TEST_PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export TEST_PROJECT_ROOT
