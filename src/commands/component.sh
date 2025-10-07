#!/usr/bin/env bash
# usage: dot component <name> [--description <desc>] [--requires <dep1,dep2>] [--tags <tag1,tag2>] [--critical]
# summary: Generate a new component with standardized structure and templates
# group: development

set -euo pipefail

# shellcheck disable=SC1091
source "$CORE_DIR/bootstrap.sh"
core_require log validation registry

COMPONENT_NAME=""
DESCRIPTION=""
REQUIRES=""
TAGS=""
CRITICAL="false"

if [[ $# -eq 0 ]]; then
    # List available components when no arguments provided
    log_info "Available components:"
    registry_list_components | while read -r component; do
        echo "  $component"
    done
    exit 0
fi

# Check for help flag first
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    grep '^# usage:' "$0" | sed 's/^# //'
    echo
    echo "Generate a new component with standardized structure."
    echo
    echo "Arguments:"
    echo "  <name>              Component name (required)"
    echo
    echo "Options:"
    echo "  --description <desc> Component description"
    echo "  --requires <deps>   Comma-separated list of dependencies"
    echo "  --tags <tags>       Comma-separated list of tags"
    echo "  --critical          Mark component as critical"
    echo
    echo "Examples:"
    echo "  dot component vim --description 'Vim editor configuration'"
    echo "  dot component docker --requires 'system-essentials' --tags 'containers,development'"
    echo
    exit 0
fi

COMPONENT_NAME="$1"
shift

while [[ $# -gt 0 ]]; do
    case $1 in
    --description)
        DESCRIPTION="$2"
        shift 2
        ;;
    --requires)
        REQUIRES="$2"
        shift 2
        ;;
    --tags)
        TAGS="$2"
        shift 2
        ;;
    --critical)
        CRITICAL="true"
        shift
        ;;
    *)
        log_error "Unknown option: $1"
        exit 1
        ;;
    esac
done

# Validate component name
if [[ -z "$COMPONENT_NAME" ]]; then
    log_error "Component name is required"
    exit 1
fi

if [[ ! "$COMPONENT_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
    log_error "Component name must start with a letter and contain only lowercase letters, numbers, and hyphens"
    exit 1
fi

COMPONENT_DIR="$COMPONENTS_DIR/$COMPONENT_NAME"

# Check if component already exists
if [[ -d "$COMPONENT_DIR" ]]; then
    log_error "Component '$COMPONENT_NAME' already exists at $COMPONENT_DIR"
    exit 1
fi

log_info "Creating new component: $COMPONENT_NAME"

# Create component directory
mkdir -p "$COMPONENT_DIR"

# Generate component.yml
log_info "Creating component.yml..."
{
    echo "name: $COMPONENT_NAME"
    if [[ -n "$DESCRIPTION" ]]; then
        echo "description: $DESCRIPTION"
    else
        echo "description: $COMPONENT_NAME installation and configuration"
    fi
    echo "parallelSafe: true"

    # Handle requires array
    if [[ -n "$REQUIRES" ]]; then
        echo "requires: [$(echo "$REQUIRES" | sed 's/,/, /g')]"
    else
        echo "requires: []"
    fi

    echo "provides: []"

    # Handle tags array
    if [[ -n "$TAGS" ]]; then
        echo "tags: [$(echo "$TAGS" | sed 's/,/, /g')]"
    else
        echo "tags: []"
    fi

    echo "critical: $CRITICAL"
    echo "healthCheck: \"command -v $COMPONENT_NAME >/dev/null 2>&1\""
    echo "files: []"
} > "$COMPONENT_DIR/component.yml"

# Generate install.sh
log_info "Creating install.sh..."
install_script_content=$(generate_install_script_template "$COMPONENT_NAME")
echo "$install_script_content" | sed "s/__COMPONENT_NAME__/$COMPONENT_NAME/g" > "$COMPONENT_DIR/install.sh"
chmod +x "$COMPONENT_DIR/install.sh"

# Validate the generated component
log_info "Validating generated component..."
if validate_component_schema "$COMPONENT_NAME" &&
   validate_component_dependencies "$COMPONENT_NAME" &&
   validate_component_install_script "$COMPONENT_NAME"; then
    log_info "✅ Component '$COMPONENT_NAME' created successfully"
    echo
    echo "Component created at: $COMPONENT_DIR"
    echo "Next steps:"
    echo "  1. Edit $COMPONENT_DIR/component.yml to customize metadata"
    echo "  2. Implement installation logic in $COMPONENT_DIR/install.sh"
    echo "  3. Test with: dot validate --component $COMPONENT_NAME"
    echo "  4. Install with: dot install --only $COMPONENT_NAME --dry-run"
else
    log_error "Generated component failed validation"
    exit 1
fi
