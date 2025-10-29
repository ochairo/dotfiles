#!/usr/bin/env bash
# validation/numbers.sh - Numeric validators

validate_integer() { [[ "$1" =~ ^-?[0-9]+$ ]]; }
validate_float() { [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; }
validate_positive_int() { [[ "$1" =~ ^[1-9][0-9]*$ ]]; }
validate_non_negative_int() { [[ "$1" =~ ^[0-9]+$ ]]; }
