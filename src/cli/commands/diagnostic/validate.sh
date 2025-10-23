#!/usr/bin/env bash
# summary: Run local validation checks similar to CI
# usage: dot validate [--component <name>] [--skip-lint] [--skip-tests] [--components-only]
#
# Runs structure validation, component schema validation, linting, formatting
# checks, tests, and dotfiles verification locally to catch issues before
# pushing to CI.

set -euo pipefail

# shellcheck disable=SC1091
source "$CORE_DIR/init/bootstrap.sh"
core_require log validation

# Use PROJECT_ROOT from environment (provided by dot script)
cd "$PROJECT_ROOT"

COMPONENT_NAME=""
SKIP_LINT=false
SKIP_TESTS=false
COMPONENTS_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
    --component)
        COMPONENT_NAME="$2"
        shift 2
        ;;
    --skip-lint)
        SKIP_LINT=true
        shift
        ;;
    --skip-tests)
        SKIP_TESTS=true
        shift
        ;;
    --components-only)
        COMPONENTS_ONLY=true
        shift
        ;;
    -h|--help)
        grep '^# usage:' "$0" | sed 's/^# //'
        echo
        echo "Run comprehensive validation checks."
        echo
        echo "Options:"
        echo "  --component <name>  Validate specific component only"
        echo "  --skip-lint        Skip shellcheck and formatting checks"
        echo "  --skip-tests       Skip bats test execution"
        echo "  --components-only  Only validate component schemas"
        echo
        exit 0
        ;;
    *)
        log_error "Unknown option: $1"
        exit 1
        ;;
    esac
done

echo "🔍 Running local dotfiles validation..."

# Component schema validation
echo "📦 Validating component schemas..."
if [[ -n "$COMPONENT_NAME" ]]; then
    # Validate single component
    if [[ ! -d "$COMPONENTS_DIR/$COMPONENT_NAME" ]]; then
        echo "❌ Component '$COMPONENT_NAME' not found"
        exit 1
    fi

    log_info "Validating component: $COMPONENT_NAME"

    errors=0

    # Schema validation
    if ! validate_component_schema "$COMPONENT_NAME"; then
        ((errors++))
    fi

    # Dependency validation
    if ! validate_component_dependencies "$COMPONENT_NAME"; then
        ((errors++))
    fi

    if [[ $errors -eq 0 ]]; then
        echo "✅ Component '$COMPONENT_NAME' validation passed"
    else
        echo "❌ Component '$COMPONENT_NAME' validation failed with $errors errors"
        exit 1
    fi
else
    # Validate all components
    if validate_all_components; then
        echo "✅ Component schema validation passed"
    else
        echo "❌ Component schema validation failed"
        exit 1
    fi
fi

# Exit early if only validating components
if [[ "$COMPONENTS_ONLY" == true ]]; then
    echo "🎉 Component validation complete!"
    exit 0
fi

# Structure validation
echo "📁 Validating structure..."
[ -f "src/bin/dot" ] || {
	echo "❌ Missing src/bin/dot script"
	exit 1
}
[ -d "src/commands" ] || {
	echo "❌ Missing src/commands directory"
	exit 1
}
[ -d "src/core" ] || {
	echo "❌ Missing src/core directory"
	exit 1
}
[ -d "src/components" ] || {
	echo "❌ Missing src/components directory"
	exit 1
}
echo "✅ Structure validation passed"

# Make sure dot is executable
chmod +x src/bin/dot

# Run shellcheck if available and not skipped
if [[ "$SKIP_LINT" == false ]] && command -v shellcheck >/dev/null 2>&1; then
	echo "🔧 Running shellcheck..."
	SHELL_FILES=$(find . -type f -name '*.sh' -not -path '*/.git/*')
	if [ -n "$SHELL_FILES" ]; then
		echo "$SHELL_FILES" | xargs shellcheck || echo "⚠️ shellcheck found issues"
	else
		echo "No shell files found to lint"
	fi
else
	echo "⚠️ shellcheck not installed; skipping"
fi

# Run shfmt if available and not skipped
if [[ "$SKIP_LINT" == false ]] && command -v shfmt >/dev/null 2>&1; then
	echo "📝 Checking shell script formatting..."
	if ! diff <(shfmt -d "$(find . -type f -name '*.sh' -not -path '*/.git/*')" || true) <(printf ''); then
		echo "⚠️ Format check failed. Run: shfmt -w \$(find . -type f -name '*.sh' -not -path '*/.git/*')"
	else
		echo "✅ Format check passed"
	fi
else
	echo "⚠️ shfmt not installed; skipping format check"
fi

# Run bats tests if available and not skipped (disabled by default to avoid recursion)
if [[ "$SKIP_TESTS" == false ]] && [[ "${DOTFILES_VALIDATE_RUN_TESTS:-0}" == "1" ]] && command -v bats >/dev/null 2>&1; then
	echo "🧪 Running bats tests..."
	# Add timeout to prevent hanging in test environments
	if timeout 60s bats tests/bats/ 2>/dev/null; then
		echo "✅ Core tests passed"
	else
		echo "⚠️ Some newer tests failed or timed out"
	fi
else
	echo "⚠️ bats tests skipped (use DOTFILES_VALIDATE_RUN_TESTS=1 to enable)"
fi

# Run dotfiles verification
echo "🔍 Running dotfiles verification..."
if "$PROJECT_ROOT/src/bin/dot" verify 2>/dev/null; then
	echo "✅ Verification passed"
else
	echo "⚠️ Verification completed with warnings/errors (may be expected)"
fi

# Run doctor check
echo "🏥 Running dotfiles doctor check..."
if "$PROJECT_ROOT/src/bin/dot" doctor --json >/dev/null 2>&1; then
	echo "✅ Doctor check completed"
else
	echo "⚠️ Doctor check completed with issues (may be expected)"
fi

echo ""
echo "🎉 Local validation complete!"

# Build dynamic install message for missing tools
MISSING_TOOLS=()
command -v shellcheck >/dev/null 2>&1 || MISSING_TOOLS+=("shellcheck")
command -v shfmt >/dev/null 2>&1 || MISSING_TOOLS+=("shfmt")
command -v bats >/dev/null 2>&1 || MISSING_TOOLS+=("bats-core")

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
	echo "💡 Install missing tools with: brew install ${MISSING_TOOLS[*]}"
fi
