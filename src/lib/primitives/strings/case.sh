#!/usr/bin/env bash
# strings/case.sh - upper/lower conversion

string_upper() { printf '%s\n' "$1" | tr '[:lower:]' '[:upper:]'; }
string_lower() { printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]'; }
