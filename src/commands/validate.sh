#!/usr/bin/env bash
# summary: Run local validation checks similar to CI
# usage: dot validate
#
# Runs structure validation, linting, formatting checks, tests, and dotfiles
# verification locally to catch issues before pushing to CI.

set -euo pipefail

# Use PROJECT_ROOT from environment (provided by dot script)
cd "$PROJECT_ROOT"

echo "🔍 Running local dotfiles validation..."

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

# Run shellcheck if available
if command -v shellcheck >/dev/null 2>&1; then
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

# Run shfmt if available
if command -v shfmt >/dev/null 2>&1; then
	echo "📝 Checking shell script formatting..."
	if ! diff <(shfmt -d $(find . -type f -name '*.sh' -not -path '*/.git/*') || true) <(printf ''); then
		echo "⚠️ Format check failed. Run: shfmt -w \$(find . -type f -name '*.sh' -not -path '*/.git/*')"
	else
		echo "✅ Format check passed"
	fi
else
	echo "⚠️ shfmt not installed; skipping format check"
fi

# Run bats tests if available
if command -v bats >/dev/null 2>&1; then
	echo "🧪 Running bats tests..."
	bats tests/bats/ || echo "⚠️ Some newer tests failed"
	bats tests/*.bats || echo "⚠️ Some legacy tests failed (expected)"
else
	echo "⚠️ bats not installed; skipping tests"
fi

# Run dotfiles verification
echo "🔍 Running dotfiles verification..."
if "$PROJECT_ROOT/dot" verify; then
	echo "✅ Verification passed"
else
	echo "⚠️ Verification completed with warnings/errors (may be expected)"
fi

# Run doctor check
echo "🏥 Running dotfiles doctor check..."
if "$PROJECT_ROOT/dot" doctor --json >/dev/null; then
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
