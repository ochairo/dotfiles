#!/usr/bin/env bash
# doctor/parts/deps.sh - Dependency graph validation

doctor_dependency_validation() {
  VALID_DEPS=1
  if ! deps_validate "${components[@]}"; then VALID_DEPS=0; fi
}
