#!/usr/bin/env bash
# usage: dot install [--help]
# summary: Install/configure components (uses saved selection if present, else all; modifiers via option commands)
# group: core

set -euo pipefail
mkdir -p "$DOTFILES_ROOT/state" 2>/dev/null || true
source "$COMMANDS_DIR/install/path.sh"
install_portable_path
DRY_RUN=0
DRY_RUN_VERBOSE=0
USE_PARALLEL=1
_INSTALL_START_EPOCH=$(date +%s)
ONLY_SET=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      self="${BASH_SOURCE[0]}"
      awk '/^# usage:/{print substr($0,3)} /^# summary:/{print substr($0,3)}' "$self"
      exit 0 ;;
    --only)
      shift
      ONLY_SET="${1:-}"; [[ -z "$ONLY_SET" ]] && msg_error "--only requires a list" && exit 1 ;;
    --only=*)
      ONLY_SET="${1#--only=}" ;;
    --dry-run)
      DRY_RUN=1 ;;
    --dry-run-verbose)
      DRY_RUN=1; DRY_RUN_VERBOSE=1 ;;
    --no-parallel)
      USE_PARALLEL=0 ;;
    --strict)
      STRICT=1 ;;
    --json)
      JSON=1 ;;
    *)
      msg_error "Unknown option: $1"; exit 1 ;;
  esac
  shift || true
done
source "$COMMANDS_DIR/install/selection.sh"
mapfile -t components_to_install < <(install_selection)
# If --only provided, override selection (comma or space delimited)
if [[ -n "$ONLY_SET" ]]; then
  # Normalize delimiters to space
  ONLY_SET="${ONLY_SET//,/ }"
  filtered=()
  for c in $ONLY_SET; do
    if [[ -d "$COMPONENTS_DIR/$c" ]]; then
      filtered+=("$c")
    else
      msg_warn "--only specifies unknown component: $c (skipping)"
    fi
  done
  if [[ ${#filtered[@]} -eq 0 ]]; then
    msg_error "--only produced empty component list"; exit 1
  fi
  components_to_install=("${filtered[@]}")
fi
source "$COMMANDS_DIR/install/dep_resolve.sh"
mapfile -t ordered < <(install_dep_resolve "${components_to_install[@]}")
if [[ ${#ordered[@]} -eq 0 ]]; then
  msg_error "Failed to resolve installation order"
  exit 1
fi
msg_info "Planned install order: ${ordered[*]}"
if [[ $DRY_RUN == 1 ]]; then
  # Use fixed dry-run implementation (dry_run_fixed.sh) to avoid legacy symbol issues
  source "$COMMANDS_DIR/install/dry_run_fixed.sh"
  install_dry_run "${ordered[@]}"
  selection_save "${ordered[*]}"
  exit 0
fi
if [[ ${DOTFILES_TRANSACTIONAL:-0} == 1 ]]; then
  source "$COMMANDS_DIR/install/transaction.sh"
  install_transaction_begin
fi
fail=0
declare -A _HEALTH_STATUS
_HEALTH_PASSES=0
_HEALTH_FAILS=0
source "$COMMANDS_DIR/install/component_serial.sh"
if [[ $USE_PARALLEL == 1 ]]; then
  source "$COMMANDS_DIR/install/parallel.sh"
  mapfile -t batches < <(install_parallel_batches "${ordered[@]}")
  if [[ ${#batches[@]} -eq 0 ]]; then
  msg_warn "Failed to generate parallel batches, falling back to serial execution"
    USE_PARALLEL=0
  else
  msg_info "Generated ${#batches[@]} parallel execution batches"
    install_parallel_exec "${batches[@]}"
  fi
fi
if [[ $USE_PARALLEL == 0 ]]; then
  source "$COMMANDS_DIR/install/serial.sh"
  install_serial_exec "${ordered[@]}"
fi
source "$COMMANDS_DIR/install/transaction_mode.sh"
install_transaction_mode "$fail"
selection_save "${ordered[*]}"
if [[ $fail == 1 ]]; then
  msg_error "Critical component failure"
  exit 1
fi
_INSTALL_TOTAL=$(($(date +%s) - _INSTALL_START_EPOCH))
msg_success "Install complete in ${_INSTALL_TOTAL}s"
source "$COMMANDS_DIR/install/timing.sh"
install_write_timing "$_INSTALL_TOTAL" _TIMINGS
source "$COMMANDS_DIR/install/health.sh"
install_health_summary _HEALTH_STATUS "$_HEALTH_PASSES" "$_HEALTH_FAILS"
