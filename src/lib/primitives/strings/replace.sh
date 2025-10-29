#!/usr/bin/env bash
# strings/replace.sh - pattern replacements & prefix/suffix removal

string_replace_first() { local s="$1" pat="$2" rep="$3"; printf '%s\n' "${s/$pat/$rep}"; }
string_replace_all() { local s="$1" pat="$2" rep="$3"; printf '%s\n' "${s//$pat/$rep}"; }
string_remove_prefix() { local s="$1" pre="$2"; printf '%s\n' "${s#"$pre"}"; }
string_remove_suffix() { local s="$1" suf="$2"; printf '%s\n' "${s%"$suf"}"; }
