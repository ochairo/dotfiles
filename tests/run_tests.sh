#!/usr/bin/env bash
# tests/run_tests.sh - Clean test runner (usage: ./tests/run_tests.sh [file])
set -euo pipefail

 C_GREEN='\033[0;32m'
 C_RED='\033[0;31m'
 C_YELLOW='\033[1;33m'
 C_BLUE='\033[0;34m'
 C_RESET='\033[0m'

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "${C_BLUE}Dotfiles Test Suite${C_RESET}\n"

if ! command -v bats >/dev/null 2>&1; then
  echo -e "${C_RED}bats not installed${C_RESET}"; exit 1
fi

if [[ $# -gt 0 ]]; then
  target="$1"
  [[ -f "$target" ]] || target="tests/$1"
  if [[ ! -f "$target" ]]; then
    echo -e "${C_RED}Test file not found: $1${C_RESET}"; exit 1
  fi
  echo -e "${C_YELLOW}Running single test: $target${C_RESET}\n"
  bats "$target"
  exit $?
fi

test_files=()
while IFS= read -r f; do
  test_files+=("$f")
done < <(find "$ROOT/tests" -type f -name "*.bats" ! -path "*/helpers/*" | sort)
if [[ ${#test_files[@]} -eq 0 ]]; then
  echo -e "${C_RED}No tests found${C_RESET}"; exit 1
fi

total=${#test_files[@]}; passed=0; failed=0

for f in "${test_files[@]}"; do
  echo -e "${C_BLUE}Running:${C_RESET} $(basename "$f")"
  if bats "$f"; then
    passed=$((passed+1))
  else
    failed=$((failed+1))
  fi
  echo ""
done

echo -e "${C_BLUE}Summary${C_RESET}"
echo -e "Total: $total"
echo -e "${C_GREEN}Passed: $passed${C_RESET}"
if [[ $failed -gt 0 ]]; then
  echo -e "${C_RED}Failed: $failed${C_RESET}"; exit 1
else
  echo -e "${C_GREEN}All tests passed ✓${C_RESET}"; exit 0
fi
