#!/usr/bin/env bash
# usage: dot doctor [--help] [--components a,b]
# summary: Consolidated diagnostics (update, health, validation, ledger status; modifiers via option commands)
# group: core
set -euo pipefail

DOCTOR_PARTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/parts"
# shellcheck source=/dev/null
source "${DOCTOR_PARTS_DIR}/args.sh"
# shellcheck source=/dev/null
source "${DOCTOR_PARTS_DIR}/components.sh"
# shellcheck source=/dev/null
source "${DOCTOR_PARTS_DIR}/update.sh"
# shellcheck source=/dev/null
source "${DOCTOR_PARTS_DIR}/health.sh"
# shellcheck source=/dev/null
source "${DOCTOR_PARTS_DIR}/deps.sh"
# shellcheck source=/dev/null
source "${DOCTOR_PARTS_DIR}/ledger.sh"
# shellcheck source=/dev/null
source "${DOCTOR_PARTS_DIR}/exit.sh"
# shellcheck source=/dev/null
source "${DOCTOR_PARTS_DIR}/output.sh"

doctor_main() {
  doctor_parse_args "$@"
  doctor_collect_components
  doctor_git_update_state
  last_selection=$(selection_load || true)
  doctor_health_checks
  doctor_dependency_validation
  doctor_ledger_summary
  doctor_compute_exit_code
  if [[ $JSON == 1 ]]; then doctor_emit_json; exit "$EXIT_CODE"; fi
  doctor_emit_text
  exit "$EXIT_CODE"
}

doctor_main "$@"
