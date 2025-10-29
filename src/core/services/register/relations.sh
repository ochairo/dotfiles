#!/usr/bin/env bash
# register/relations.sh - requires / provides relations
components_requires() {
    local name="$1" file; file=$(components_meta_path "$name") || return 0; [[ -f "$file" ]] || return 0
    awk '
        tolower($0) ~ /^requires:/ {
            if ($0 ~ /\[/) { line=$0; sub(/^[^[]*\[/,"",line); sub(/].*$/, "", line); gsub(/,/," ",line); print line; exit }
            inlist=1; next }
        inlist==1 && /\[/ { line=$0; gsub(/\[/,"",line); gsub(/].*/,"",line); gsub(/,/," ",line); print line; exit }
        inlist==1 && /^  - / { sub(/^  - */,""); print }
        inlist==1 && /^[a-zA-Z]/ { exit }
    ' "$file" | tr ' ' '\n' | sed '/^$/d'
}
components_provides() {
    local name="$1" file; file=$(components_meta_path "$name") || return 0; [[ -f "$file" ]] || return 0
    awk '
        tolower($0) ~ /^provides:/ {
            if ($0 ~ /\[/) { line=$0; sub(/^[^[]*\[/,"",line); sub(/].*$/, "", line); gsub(/,/," ",line); print line; exit }
            inlist=1; next }
        inlist==1 && /\[/ { line=$0; gsub(/\[/,"",line); gsub(/].*/,"",line); gsub(/,/," ",line); print line; exit }
        inlist==1 && /^  - / { sub(/^  - */,""); print }
        inlist==1 && /^[a-zA-Z]/ { exit }
    ' "$file" | tr ' ' '\n' | sed '/^$/d'
}
