#!/usr/bin/env bash
# core/validation.sh - Component schema validation and standardization
set -euo pipefail

source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/constants.sh"
source "$DOTFILES_ROOT/core/log.sh"

# =============================================================================
# COMPONENT SCHEMA VALIDATION
# =============================================================================

# Component schema definition
COMPONENT_SCHEMA_REQUIRED_FIELDS=(
    "name"
    "parallelSafe"
    "critical"
    "healthCheck"
)

COMPONENT_SCHEMA_OPTIONAL_FIELDS=(
    "description"
    "requires"
    "provides"
    "tags"
    "files"
    "packages"
    "version"
    "homepage"
    "documentation"
    "command"
    "packageName"
    "installMethod"
    "platforms"
)

COMPONENT_SCHEMA_ALL_FIELDS=("${COMPONENT_SCHEMA_REQUIRED_FIELDS[@]}" "${COMPONENT_SCHEMA_OPTIONAL_FIELDS[@]}")

# Validate a single component's YAML structure
validate_component_schema() {
    local component_name="$1"
    local component_file="$COMPONENTS_DIR/$component_name/component.yml"
    local errors=0

    if [[ ! -f "$component_file" ]]; then
        log_error "Component $component_name: missing component.yml file"
        return 1
    fi

    log_debug "Validating component schema: $component_name"

    # Check required fields
    for field in "${COMPONENT_SCHEMA_REQUIRED_FIELDS[@]}"; do
        if ! grep -q "^$field:" "$component_file"; then
            log_error "Component $component_name: missing required field '$field'"
            ((errors++))
        fi
    done

    # Check for unknown fields
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue

        # Extract field name (before colon)
        if [[ "$line" =~ ^([a-zA-Z][a-zA-Z0-9_]*): ]]; then
            local field="${BASH_REMATCH[1]}"
            local is_known=false

            for known_field in "${COMPONENT_SCHEMA_ALL_FIELDS[@]}"; do
                if [[ "$field" == "$known_field" ]]; then
                    is_known=true
                    break
                fi
            done

            if [[ "$is_known" == false ]]; then
                log_warn "Component $component_name: unknown field '$field'"
            fi
        fi
    done < "$component_file"

    # Validate specific field formats
    _validate_component_field_formats "$component_name" "$component_file" || ((errors++))

    if [[ $errors -eq 0 ]]; then
        log_debug "Component $component_name: schema validation passed"
        return 0
    else
        log_error "Component $component_name: schema validation failed with $errors errors"
        return 1
    fi
}

# Validate specific field formats and values
_validate_component_field_formats() {
    local component_name="$1"
    local component_file="$2"
    local errors=0

    # Validate name matches directory
    local declared_name
    declared_name=$(grep "^name:" "$component_file" | cut -d':' -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    if [[ "$declared_name" != "$component_name" ]]; then
        log_error "Component $component_name: name field '$declared_name' doesn't match directory name"
        ((errors++))
    fi

    # Validate boolean fields
    for bool_field in "parallelSafe" "critical"; do
        if grep -q "^$bool_field:" "$component_file"; then
            local value
            value=$(grep "^$bool_field:" "$component_file" | cut -d':' -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
            if [[ "$value" != "true" && "$value" != "false" ]]; then
                log_error "Component $component_name: $bool_field must be 'true' or 'false', got '$value'"
                ((errors++))
            fi
        fi
    done

    # Validate healthCheck is not empty
    if grep -q "^healthCheck:" "$component_file"; then
        local health_check
        health_check=$(grep "^healthCheck:" "$component_file" | cut -d':' -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        if [[ -z "$health_check" || "$health_check" == '""' || "$health_check" == "''" ]]; then
            log_error "Component $component_name: healthCheck cannot be empty"
            ((errors++))
        fi
    fi

    return $errors
}

# Validate component dependencies exist
validate_component_dependencies() {
    local component_name="$1"
    local component_file="$COMPONENTS_DIR/$component_name/component.yml"
    local errors=0

    if [[ ! -f "$component_file" ]]; then
        return 1
    fi

    # Extract requires dependencies
    local requires
    requires=$(awk '
        tolower($0) ~ /^requires:/ {
            if ($0 ~ /\[/) {
                line=$0; sub(/^[^[]*\[/,"",line); sub(/].*$/, "", line);
                gsub(/,/ ," ", line); gsub(/"/, "", line); gsub(/'\''/, "", line);
                print line; exit
            }
            inlist=1; next
        }
        inlist==1 && /\[/ {
            line=$0; gsub(/\[/ ,"", line); gsub(/].*/, "", line);
            gsub(/,/ ," ", line); gsub(/"/, "", line); gsub(/'\''/, "", line);
            print line; exit
        }
    ' "$component_file" | tr ' ' '\n' | sed '/^$/d')

    if [[ -n "$requires" ]]; then
        while IFS= read -r dep; do
            dep=$(echo "$dep" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
            if [[ -n "$dep" && ! -d "$COMPONENTS_DIR/$dep" ]]; then
                log_error "Component $component_name: dependency '$dep' does not exist"
                ((errors++))
            fi
        done <<< "$requires"
    fi

    return $errors
}

# Validate component installation configuration (YAML-based)
validate_component_install_script() {
    local component_name="$1"
    local component_yml="$COMPONENTS_DIR/$component_name/component.yml"
    local errors=0

    # Check if component.yml exists
    if [[ ! -f "$component_yml" ]]; then
        log_error "Component $component_name: missing component.yml"
        ((errors++))
        return $errors
    fi

    # Check if component has at least one platform configured
    if ! grep -q "^platforms:" "$component_yml"; then
        log_error "Component $component_name: missing platforms section in component.yml"
        ((errors++))
    fi

    # Optional: Check if installMethod is specified for configured platforms
    local has_install_method=false
    if grep -q "installMethod:" "$component_yml"; then
        has_install_method=true
    fi

    if [[ "$has_install_method" == "false" ]]; then
        log_warn "Component $component_name: no installMethod found in any platform (may be config-only component)"
    fi

    return $errors
}

# Validate all components in the system
validate_all_components() {
    local total_errors=0
    local components

    log_info "Validating all components..."

    # Get all component directories
    if [[ ! -d "$COMPONENTS_DIR" ]]; then
        log_error "Components directory not found: $COMPONENTS_DIR"
        return 1
    fi

    mapfile -t components < <(find "$COMPONENTS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)

    if [[ ${#components[@]} -eq 0 ]]; then
        log_warn "No components found in $COMPONENTS_DIR"
        return 0
    fi

    for component in "${components[@]}"; do
        log_debug "Validating component: $component"

        # Schema validation
        if ! validate_component_schema "$component"; then
            ((total_errors++))
        fi

        # Dependency validation
        if ! validate_component_dependencies "$component"; then
            ((total_errors++))
        fi

        # Install script validation
        if ! validate_component_install_script "$component"; then
            ((total_errors++))
        fi
    done

    if [[ $total_errors -eq 0 ]]; then
        log_info "All ${#components[@]} components passed validation"
        return 0
    else
        log_error "Component validation failed: $total_errors errors found across ${#components[@]} components"
        return 1
    fi
}

# Generate install script template
generate_install_script_template() {
    local component_name="$1"

    cat << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Component: __COMPONENT_NAME__

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log os error

# Set up error handlers
setup_error_handlers

component_install() {
    local component_name="__COMPONENT_NAME__"

    log_info "Installing $component_name"

    # Check if already installed
    if command -v __COMPONENT_NAME__ >/dev/null 2>&1; then
        log_info "$component_name already installed"
        return 0
    fi

    # Install via package manager with proper error handling
    if command -v brew >/dev/null 2>&1; then
        if ! retry_with_backoff 3 "brew install __COMPONENT_NAME__" "$component_name"; then
            recover_package_manager_error "brew" "$component_name" "brew install failed"
            return $ERROR_INSTALLATION_FAILED
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        if ! safe_execute "sudo apt-get update -y" "$component_name" true; then
            return $ERROR_INSTALLATION_FAILED
        fi
        if ! retry_with_backoff 3 "sudo apt-get install -y __COMPONENT_NAME__" "$component_name"; then
            recover_package_manager_error "apt-get" "$component_name" "apt-get install failed"
            return $ERROR_INSTALLATION_FAILED
        fi
    elif command -v dnf >/dev/null 2>&1; then
        if ! retry_with_backoff 3 "sudo dnf install -y __COMPONENT_NAME__" "$component_name"; then
            recover_package_manager_error "dnf" "$component_name" "dnf install failed"
            return $ERROR_INSTALLATION_FAILED
        fi
    else
        error_installation_failed "$component_name" "No supported package manager found (brew, apt-get, or dnf)"
        return $ERROR_INSTALLATION_FAILED
    fi

    # Verify installation
    if ! command -v __COMPONENT_NAME__ >/dev/null 2>&1; then
        error_installation_failed "$component_name" "Installation appeared to succeed but command not found"
        return $ERROR_INSTALLATION_FAILED
    fi

    log_info "Successfully installed $component_name"
    return 0
}

component_install "$@"
EOF
}
