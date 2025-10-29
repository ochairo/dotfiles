#!/usr/bin/env bash
# strings/predicates.sh - starts/ends/contains

string_starts_with() { local s="$1" p="$2"; [[ "$s" == "$p"* ]]; }
string_ends_with() { local s="$1" suf="$2"; [[ "$s" == *"$suf" ]]; }
string_contains() { local s="$1" sub="$2"; [[ "$s" == *"$sub"* ]]; }
