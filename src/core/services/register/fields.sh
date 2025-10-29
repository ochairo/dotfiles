#!/usr/bin/env bash
# register/fields.sh - Basic field extraction, description, tags, platform fields

components_get_field() {
    local name="$1" field="$2" file; file=$(components_meta_path "$name") || return 1
    [[ -f "$file" ]] || return 1
    awk -F': *' -v k="$field" 'tolower($1)==tolower(k){sub(/^[^:]*:[[:space:]]*/, "");print;exit}' "$file"
}
components_description() { components_get_field "$1" "description"; }
components_tags() {
    local name="$1" file; file=$(components_meta_path "$name") || return 1; [[ -f "$file" ]] || return 1
    awk '/^tags:/ { if ($0 ~ /\[/) { line=$0; sub(/^[^[]*\[/,"",line); sub(/].*$/, "", line); gsub(/,/,",", line); print line; exit } }' "$file"
}
# Platform field (simple or nested parent.child)
components_platform_field() {
    local component="$1" platform="$2" field="$3" file; file=$(components_meta_path "$component") || return 1; [[ -f "$file" ]] || return 1
    if [[ "$field" == *.* ]]; then
        local parent_field="${field%%.*}" child_field="${field#*.}"
        awk -v platform="$platform" -v parent="$parent_field" -v child="$child_field" '
            /^platforms:/ { in_platforms=1; next }
            in_platforms && /^[[:space:]]*'"$platform"':/ { in_platform=1; next }
            in_platform && /^[[:space:]]*[a-zA-Z]/ && !/^[[:space:]]*'"$parent_field"'/ { if (in_parent) in_parent=0; if (!match($0, /^[[:space:]]*'"$parent_field"'/)) in_platform=0 }
            in_platform && /^[[:space:]]*'"$parent_field"':/ { in_parent=1; next }
            in_parent && /^[[:space:]]*'"$child_field"':/ { gsub(/^[[:space:]]*'"$child_field"':[[:space:]]*"?/, ""); gsub(/"?[[:space:]]*$/, ""); print; exit }
            /^[a-zA-Z]/ && !/^platforms:/ { in_platforms=0; in_platform=0; in_parent=0 }
        ' "$file"
    else
        awk -v platform="$platform" -v field="$field" '
            /^platforms:/ { in_platforms=1; next }
            in_platforms && /^[[:space:]]*'"$platform"':/ { in_platform=1; next }
            in_platform && /^[[:space:]]*[a-z]+:/ && !/^[[:space:]]*'"$field"':/ { in_platform=0 }
            in_platform && /^[[:space:]]*'"$field"':/ { gsub(/^[[:space:]]*'"$field"':[[:space:]]*"?/, ""); gsub(/"?[[:space:]]*$/, ""); print; exit }
            /^[a-zA-Z]/ && !/^platforms:/ { in_platforms=0; in_platform=0 }
        ' "$file"
    fi
}

# components_platform_block_field <component> <platform> <field>
# Extracts a multiline YAML block value (e.g. postInstall: |) preserving newlines.
# Returns the raw block content trimmed of the leading indentation used in the block.
components_platform_block_field() {
    local component="$1" platform="$2" field="$3" file; file=$(components_meta_path "$component") || return 1; [[ -f "$file" ]] || return 1
    awk -v platform="$platform" -v field="$field" '
        /^platforms:/ { in_platforms=1; next }
        in_platforms && $0 ~ "^[[:space:]]*" platform ":" { in_platform=1; next }
        in_platform && $0 ~ "^[[:space:]]*" field ": *\\|" { in_block=1; block_indent=match($0,/^ */); next }
        in_block {
            current_indent=match($0,/^ */)
            if (current_indent <= block_indent && $0 ~ /^[[:space:]]*[a-zA-Z0-9_-]+:/) { exit }
            # Strip leading spaces (keep relative indentation minimal)
            sub(/^ {0,}/,"")
            print
        }
    ' "$file"
}
export -f components_platform_block_field
