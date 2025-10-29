#!/usr/bin/env bash
# doctor/parts/exit.sh - Exit code computation

doctor_compute_exit_code() {
  EXIT_CODE=0
  if [[ ${#critical_failing[@]} -gt 0 ]]; then EXIT_CODE=2; fi
  if [[ $STRICT == 1 && $health_fail -gt 0 && $EXIT_CODE -lt 2 ]]; then EXIT_CODE=1; fi
  if [[ $VALID_DEPS == 0 && $EXIT_CODE -lt 2 ]]; then EXIT_CODE=1; fi
}
