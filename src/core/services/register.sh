#!/usr/bin/env bash
# components.sh - Dotfiles component registry and metadata management
# Domain-specific logic for managing dotfiles components

# Prevent double loading
[[ -n "${DOTFILES_COMPONENTS_LOADED:-}" ]] && return 0
readonly DOTFILES_COMPONENTS_LOADED=1

# Component directory (can be overridden)
: "${COMPONENTS_DIR:=$HOME/.dotfiles/components}"

# List all available components
# Returns: component names (one per line)
# Example: components_list
components_list() {
    if [[ ! -d "$COMPONENTS_DIR" ]]; then
        return 1
    fi

    find "$COMPONENTS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

# Get path to component metadata file
# Args: component_name
# Returns: path to component.yml
# Example: yml=$(components_meta_path "git")
components_meta_path() {
    echo "$COMPONENTS_DIR/$1/component.yml"
}

# Check if component exists
# Args: component_name
# Returns: 0 if exists, 1 otherwise
# Example: if components_exists "git"; then echo "Exists"; fi
components_exists() {
    local name="${1}"
    [[ -f "$(components_meta_path "$name")" ]]
}

# Get field value from component metadata
# Args: component_name, field_name
# Returns: field value
# Example: desc=$(components_get_field "git" "description")
components_get_field() {
    local name="${1}"
    local field="${2}"
    local file

    file=$(components_meta_path "$name")

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    awk -F': *' -v k="$field" 'tolower($1)==tolower(k){sub(/^[^:]*:[[:space:]]*/, "");print;exit}' "$file"
}

# Get component description
# Args: component_name
# Returns: description string
# Example: desc=$(components_description "git")
components_description() {
    components_get_field "$1" "description"
}

# Get component tags
# Args: component_name
# Returns: comma-separated tags
# Example: tags=$(components_tags "git")
components_tags() {
    local name="${1}"
    local file

    file=$(components_meta_path "$name")

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    # Extract tags array from YAML: tags: [cli, git]
    awk '/^tags:/ {
        if ($0 ~ /\[/) {
            line=$0
            sub(/^[^[]*\[/,"",line)
            sub(/].*$/, "", line)
            gsub(/,/ ,",", line)
            print line
            exit
        }
    }' "$file"
}

# Get component dependencies (requires)
# Args: component_name
# Returns: dependency names (one per line)
# Example: components_requires "neovim"
components_requires() {
    local name="${1}"
    local file

    file=$(components_meta_path "$name")

    if [[ ! -f "$file" ]]; then
        return 0
    fi

    # Support two forms:
    # requires: [a, b]
    # requires:
    #   - a
    #   - b
    awk '
        tolower($0) ~ /^requires:/ {
            # if list starts on same line
            if ($0 ~ /\[/) {
                line=$0
                sub(/^[^[]*\[/,"",line)
                sub(/].*$/, "", line)
                gsub(/,/ ," ", line)
                print line
                exit
            }
            inlist=1
            next
        }
        inlist==1 && /\[/ {
            line=$0
            gsub(/\[/ ,"", line)
            gsub(/].*/, "", line)
            gsub(/,/ ," ", line)
            print line
            exit
        }
        inlist==1 && /^  - / {
            sub(/^  - */, "")
            print
        }
        inlist==1 && /^[a-zA-Z]/ {
            exit
        }
    ' "$file" | tr ' ' '\n' | sed '/^$/d'
}

# Get what component provides
# Args: component_name
# Returns: provided capabilities (one per line)
# Example: components_provides "pyenv"
components_provides() {
    local name="${1}"
    local file

    file=$(components_meta_path "$name")

    if [[ ! -f "$file" ]]; then
        return 0
    fi

    awk '
        tolower($0) ~ /^provides:/ {
            if ($0 ~ /\[/) {
                line=$0
                sub(/^[^[]*\[/,"",line)
                sub(/].*$/, "", line)
                gsub(/,/ ," ", line)
                print line
                exit
            }
            inlist=1
            next
        }
        inlist==1 && /\[/ {
            line=$0
            gsub(/\[/ ,"", line)
            gsub(/].*/, "", line)
            gsub(/,/ ," ", line)
            print line
            exit
        }
        inlist==1 && /^  - / {
            sub(/^  - */, "")
            print
        }
        inlist==1 && /^[a-zA-Z]/ {
            exit
        }
    ' "$file" | tr ' ' '\n' | sed '/^$/d'
}

# Check if component is parallel safe
# Args: component_name
# Returns: 0 if parallel safe, 1 otherwise
# Example: if components_is_parallel_safe "git"; then echo "Can run in parallel"; fi
components_is_parallel_safe() {
    local value
    value=$(components_get_field "$1" "parallelSafe")
    [[ "$value" == "true"* ]]
}

# Check if component is critical
# Args: component_name
# Returns: 0 if critical, 1 otherwise
# Example: if components_is_critical "zsh"; then echo "Critical component"; fi
components_is_critical() {
    local value
    value=$(components_get_field "$1" "critical")
    [[ "$value" == "true"* ]]
}

# Get component health check command
# Args: component_name
# Returns: health check command string
# Example: check=$(components_health_check "git")
components_health_check() {
    local raw
    raw=$(components_get_field "$1" "healthCheck" || echo "")

    # Trim surrounding quotes (single or double) if present
    if [[ ${#raw} -ge 2 ]]; then
        case $raw in
            "\""*"\"") raw=${raw:1:${#raw}-2} ;;
            "'"*"'") raw=${raw:1:${#raw}-2} ;;
        esac
    fi

    printf '%s' "$raw"
}

# Run health check for component
# Args: component_name
# Returns: 0 if healthy, 1 otherwise
# Example: if components_check_health "git"; then echo "Healthy"; fi
components_check_health() {
    local name="${1}"
    local check

    check=$(components_health_check "$name")

    if [[ -z "$check" ]]; then
        return 1
    fi

    eval "$check" >/dev/null 2>&1
}

# Get platform-specific field from component
# Args: component_name, platform, field_name
# Returns: field value
# Example: pkg=$(components_platform_field "git" "macos" "packageName")
components_platform_field() {
    local component="${1}"
    local platform="${2}"
    local field="${3}"
    local file

    file=$(components_meta_path "$component")

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    # Handle nested fields (e.g., repositorySetup.type)
    if [[ "$field" == *.* ]]; then
        local parent_field="${field%%.*}"
        local child_field="${field#*.}"

        awk -v platform="$platform" -v parent="$parent_field" -v child="$child_field" '
            /^platforms:/ { in_platforms = 1; next }
            in_platforms && /^[[:space:]]*'"$platform"':/ { in_platform = 1; next }
            in_platform && /^[[:space:]]*[a-zA-Z]/ && !/^[[:space:]]*'"$parent_field"'/ {
                if (in_parent) in_parent = 0
                if (!match($0, /^[[:space:]]*'"$parent_field"'/)) in_platform = 0
            }
            in_platform && /^[[:space:]]*'"$parent_field"':/ { in_parent = 1; next }
            in_parent && /^[[:space:]]*'"$child_field"':/ {
                gsub(/^[[:space:]]*'"$child_field"':[[:space:]]*"?/, "")
                gsub(/"?[[:space:]]*$/, "")
                print
                exit
            }
            /^[a-zA-Z]/ && !/^platforms:/ { in_platforms = 0; in_platform = 0; in_parent = 0 }
        ' "$file"
    else
        # Handle simple fields
        awk -v platform="$platform" -v field="$field" '
            /^platforms:/ { in_platforms = 1; next }
            in_platforms && /^[[:space:]]*'"$platform"':/ { in_platform = 1; next }
            in_platform && /^[[:space:]]*[a-z]+:/ && !/^[[:space:]]*'"$field"':/ { in_platform = 0 }
            in_platform && /^[[:space:]]*'"$field"':/ {
                gsub(/^[[:space:]]*'"$field"':[[:space:]]*"?/, "")
                gsub(/"?[[:space:]]*$/, "")
                print
                exit
            }
            /^[a-zA-Z]/ && !/^platforms:/ { in_platforms = 0; in_platform = 0 }
        ' "$file"
    fi
}

# Count total components
# Returns: number of components
# Example: total=$(components_count)
components_count() {
    components_list | wc -l | tr -d ' '
}

# Filter components by tag
# Args: tag_name
# Returns: matching component names (one per line)
# Example: components_by_tag "cli"
components_by_tag() {
    local tag="${1}"

    components_list | while read -r comp; do
        local tags
        tags=$(components_tags "$comp")
        if [[ "$tags" == *"$tag"* ]]; then
            echo "$comp"
        fi
    done
}

# Get all tags across all components
# Returns: unique tags (one per line)
# Example: components_all_tags
components_all_tags() {
    components_list | while read -r comp; do
        components_tags "$comp" | tr ',' '\n'
    done | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sort -u | grep -v '^$'
}
