#!/usr/bin/env bash
# validation/strings.sh - String validators

validate_not_empty() { [[ -n "$1" ]]; }
validate_length() { local v="$1" min="$2" max="$3"; local len=${#v}; [[ $len -ge $min && $len -le $max ]]; }
validate_alphanumeric() { [[ "$1" =~ ^[[:alnum:]]+$ ]]; }
validate_identifier() { [[ "$1" =~ ^[[:alnum:]_-]+$ ]]; }
