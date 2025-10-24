#!/usr/bin/env bash
# run_tests.sh - Test runner for dotfiles project
# Usage: ./tests/run_tests.sh [test_file.bats]

set -euo pipefail

# Colors
C_GREEN='\033[0;32m'
C_RED='\033[0;31m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_RESET='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${C_BLUE}=====================================${C_RESET}"
echo -e "${C_BLUE}  Dotfiles Test Suite${C_RESET}"
echo -e "${C_BLUE}=====================================${C_RESET}"
echo ""

# Check if bats is installed
if ! command -v bats >/dev/null 2>&1; then
  echo -e "${C_RED}Error: bats is not installed${C_RESET}"
  echo ""
  echo "Install bats:"
  if [[ "$(uname)" == "Darwin" ]]; then
    echo "  brew install bats-core"
  elif [[ "$(uname)" == "Linux" ]]; then
    echo "  # Ubuntu/Debian:"
    echo "  sudo apt-get install bats"
    echo ""
    echo "  # Or install from source:"
    echo "  git clone https://github.com/bats-core/bats-core.git"
    echo "  cd bats-core && sudo ./install.sh /usr/local"
  fi
  exit 1
fi

echo -e "${C_GREEN}✓${C_RESET} bats version: $(bats --version)"
echo ""

# Run specific test or all tests
cd "$PROJECT_ROOT"

if [[ $# -gt 0 ]]; then
  # Run specific test file
  test_file="$1"
  if [[ ! -f "$test_file" ]]; then
    test_file="tests/$1"
  fi

  if [[ ! -f "$test_file" ]]; then
    echo -e "${C_RED}Error: Test file not found: $1${C_RESET}"
    exit 1
  fi

  echo -e "${C_YELLOW}Running: $test_file${C_RESET}"
  echo ""
  bats "$test_file"
else
  # Run all tests
  echo -e "${C_YELLOW}Running all tests...${C_RESET}"
  echo ""

  test_files=(
    "tests/lib_primitives.bats"
    "tests/lib_systemdetections.bats"
    "tests/core_modules.bats"
    "tests/cli_integration.bats"
  )

  failed=0
  passed=0

  for test_file in "${test_files[@]}"; do
    if [[ -f "$test_file" ]]; then
      echo ""
      echo -e "${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
      echo -e "${C_BLUE}  $(basename "$test_file")${C_RESET}"
      echo -e "${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
      echo ""

      if bats "$test_file"; then
        passed=$((passed + 1))
      else
        failed=$((failed + 1))
      fi
    fi
  done

  echo ""
  echo -e "${C_BLUE}=====================================${C_RESET}"
  echo -e "${C_BLUE}  Test Summary${C_RESET}"
  echo -e "${C_BLUE}=====================================${C_RESET}"
  echo -e "${C_GREEN}Passed: $passed${C_RESET}"
  if [[ $failed -gt 0 ]]; then
    echo -e "${C_RED}Failed: $failed${C_RESET}"
    exit 1
  else
    echo -e "${C_GREEN}All tests passed! ✓${C_RESET}"
    exit 0
  fi
fi
