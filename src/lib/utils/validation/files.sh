#!/usr/bin/env bash
# validation/files.sh - File & command validation

validate_file_exists() { local f="$1"; [[ -f $f && -r $f ]]; }
validate_file_writable() { local f="$1"; if [[ -f $f ]]; then [[ -w $f ]]; else local d; d=$(dirname "$f"); [[ -d $d && -w $d ]]; fi }
validate_dir_exists() { local d="$1"; [[ -d $d && -r $d ]]; }
validate_dir_writable() { local d="$1"; [[ -d $d && -w $d ]]; }
validate_command() { command -v "$1" >/dev/null 2>&1; }
