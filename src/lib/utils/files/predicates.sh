#!/usr/bin/env bash
# files/predicates.sh - Predicate helpers

file_readable() { local file="$1"; [[ -n $file ]] || { msg_error "file_readable requires file path"; return 1; }; [[ -r $file ]]; }
file_writable() { local file="$1"; [[ -n $file ]] || { msg_error "file_writable requires file path"; return 1; }; [[ -w $file ]]; }
