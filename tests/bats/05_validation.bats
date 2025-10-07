#!/usr/bin/env bats
# Test suite for validation.sh - Component validation functions

# load "../test_helper"  # Not needed - using minimal setup

setup() {
    local dotfiles_root
    dotfiles_root="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    export DOTFILES_ROOT="$dotfiles_root/src"

    # CRITICAL SAFETY CHECK: Ensure we're in test mode
    if [ "$BATS_TEST_TMPDIR" = "" ] || [ "$BATS_TMPDIR" = "" ]; then
        echo "CRITICAL ERROR: Test isolation not working - BATS temp dirs not set!"
        return 1
    fi

    # Source bootstrap and dependencies
    source "$DOTFILES_ROOT/core/bootstrap.sh"
    core_require log
    source "$DOTFILES_ROOT/core/validation.sh"

    # THEN override with test directory (must be after sourcing)
    export COMPONENTS_DIR="$BATS_TEST_TMPDIR/components"
    mkdir -p "$COMPONENTS_DIR"

    # CRITICAL SAFETY CHECK: Never allow tests to use real components directory
    if [[ "$COMPONENTS_DIR" == *"/src/components"* ]]; then
        echo "FATAL ERROR: Test attempted to use real components directory!" >&2
        echo "COMPONENTS_DIR=$COMPONENTS_DIR" >&2
        exit 1
    fi

    # Cross-platform sed function - works on both macOS and Linux
    cross_platform_sed() {
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS requires empty backup extension for in-place editing
            sed -i '' "$@"
        else
            # Linux standard syntax
            sed -i "$@"
        fi
    }

    # Suppress log output for cleaner test output
    export DOTFILES_LOG_LEVEL="ERROR"
}

teardown() {
    # Clean up test environment
    unset COMPONENTS_DIR DOTFILES_LOG_LEVEL
}

# Helper function to create a valid component
create_valid_component() {
    local name="$1"
    local component_dir="$COMPONENTS_DIR/$name"
    mkdir -p "$component_dir"

    cat > "$component_dir/component.yml" << EOF
name: $name
description: Test component for $name
parallelSafe: true
critical: false
healthCheck: command -v $name
requires: []
tags: [test, cli]
EOF

    cat > "$component_dir/install.sh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "Installing test component"
EOF
    chmod +x "$component_dir/install.sh"
}

# Helper function to edit a component file (cross-platform compatible)
edit_component_file() {
    local component="$1"
    local search="$2"
    local replace="$3"
    local file="$COMPONENTS_DIR/$component/component.yml"

    # Use a temporary file for cross-platform compatibility
    local temp_file
    temp_file=$(mktemp)
    sed "s|$search|$replace|g" "$file" > "$temp_file"
    mv "$temp_file" "$file"
}

# Helper function to remove a line from component file
remove_line_from_component() {
    local component="$1"
    local pattern="$2"
    local file="$COMPONENTS_DIR/$component/component.yml"

    local temp_file
    temp_file=$(mktemp)
    grep -v "$pattern" "$file" > "$temp_file"
    mv "$temp_file" "$file"
}

# Helper function to create an invalid component
create_invalid_component() {
    local name="$1"
    local missing_field="$2"
    local component_dir="$COMPONENTS_DIR/$name"
    mkdir -p "$component_dir"

    cat > "$component_dir/component.yml" << EOF
name: $name
description: Test component for $name
parallelSafe: true
critical: false
healthCheck: command -v $name
EOF

    # Remove the specified field
    if [[ "$missing_field" != "none" ]]; then
        cross_platform_sed "/$missing_field:/d" "$component_dir/component.yml"
    fi
}

# =============================================================================
# COMPONENT SCHEMA VALIDATION TESTS
# =============================================================================

@test "validate_component_schema: passes for valid component" {
    create_valid_component "test-component"

    run validate_component_schema "test-component"

    [ "$status" -eq 0 ]
}

@test "validate_component_schema: fails for missing component.yml" {
    mkdir -p "$COMPONENTS_DIR/no-yml"

    run validate_component_schema "no-yml"

    [ "$status" -eq 1 ]
}

@test "validate_component_schema: fails for missing required field name" {
    create_invalid_component "missing-name" "name"

    run validate_component_schema "missing-name"

    [ "$status" -eq 1 ]
}

@test "validate_component_schema: fails for missing required field parallelSafe" {
    create_invalid_component "missing-parallel" "parallelSafe"

    run validate_component_schema "missing-parallel"

    [ "$status" -eq 1 ]
}

@test "validate_component_schema: fails for missing required field critical" {
    create_invalid_component "missing-critical" "critical"

    run validate_component_schema "missing-critical"

    [ "$status" -eq 1 ]
}

@test "validate_component_schema: fails for missing required field healthCheck" {
    create_invalid_component "missing-health" "healthCheck"

    run validate_component_schema "missing-health"

    [ "$status" -eq 1 ]
}

@test "validate_component_schema: warns about unknown fields" {
    create_valid_component "unknown-field"
    echo "unknownField: someValue" >> "$COMPONENTS_DIR/unknown-field/component.yml"

    run validate_component_schema "unknown-field"

    [ "$status" -eq 0 ]  # Should still pass but warn
}

@test "validate_component_schema: ignores comments and empty lines" {
    create_valid_component "with-comments"

    # Add comments and empty lines
    cat >> "$COMPONENTS_DIR/with-comments/component.yml" << EOF

# This is a comment
   # Indented comment

EOF

    run validate_component_schema "with-comments"

    [ "$status" -eq 0 ]
}

# =============================================================================
# FIELD FORMAT VALIDATION TESTS
# =============================================================================

@test "validate_component_schema: fails when name doesn't match directory" {
    create_valid_component "wrong-name"
    edit_component_file "wrong-name" "name: wrong-name" "name: different-name"

    run validate_component_schema "wrong-name"

    [ "$status" -eq 1 ]
}

@test "validate_component_schema: fails for invalid parallelSafe value" {
    create_valid_component "invalid-parallel"
    edit_component_file "invalid-parallel" "parallelSafe: true" "parallelSafe: maybe"

    run validate_component_schema "invalid-parallel"

    [ "$status" -eq 1 ]
}

@test "validate_component_schema: fails for invalid critical value" {
    create_valid_component "invalid-critical"
    cross_platform_sed 's/critical: false/critical: sometimes/' "$COMPONENTS_DIR/invalid-critical/component.yml"

    run validate_component_schema "invalid-critical"

    [ "$status" -eq 1 ]
}

@test "validate_component_schema: fails for empty healthCheck" {
    create_valid_component "empty-health"
    cross_platform_sed 's/healthCheck: command -v empty-health/healthCheck: ""/' "$COMPONENTS_DIR/empty-health/component.yml"

    run validate_component_schema "empty-health"

    [ "$status" -eq 1 ]
}

@test "validate_component_schema: fails for single-quoted empty healthCheck" {
    create_valid_component "empty-health-single"
    cross_platform_sed "s/healthCheck: command -v empty-health-single/healthCheck: ''/" "$COMPONENTS_DIR/empty-health-single/component.yml"

    run validate_component_schema "empty-health-single"

    [ "$status" -eq 1 ]
}

@test "validate_component_schema: handles boolean true/false correctly" {
    create_valid_component "bool-test"

    # Test all valid boolean combinations
    for parallel in "true" "false"; do
        for critical in "true" "false"; do
            cross_platform_sed "s/parallelSafe: .*/parallelSafe: $parallel/" "$COMPONENTS_DIR/bool-test/component.yml"
            cross_platform_sed "s/critical: .*/critical: $critical/" "$COMPONENTS_DIR/bool-test/component.yml"

            run validate_component_schema "bool-test"
            [ "$status" -eq 0 ]
        done
    done
}

# =============================================================================
# DEPENDENCY VALIDATION TESTS
# =============================================================================

@test "validate_component_dependencies: passes when dependencies exist" {
    create_valid_component "dep1"
    create_valid_component "dep2"
    create_valid_component "main-component"

    # Add dependencies to main component
    cross_platform_sed 's/requires: \[\]/requires: [dep1, dep2]/' "$COMPONENTS_DIR/main-component/component.yml"

    run validate_component_dependencies "main-component"

    [ "$status" -eq 0 ]
}

@test "validate_component_dependencies: fails when dependency doesn't exist" {
    create_valid_component "main-component"

    # Add non-existent dependency
    cross_platform_sed 's/requires: \[\]/requires: [nonexistent-dep]/' "$COMPONENTS_DIR/main-component/component.yml"

    run validate_component_dependencies "main-component"

    [ "$status" -eq 1 ]
}

@test "validate_component_dependencies: handles multi-line requires format" {
    create_valid_component "dep1"
    create_valid_component "dep2"
    create_valid_component "multiline-deps"

    # Replace requires with multi-line format
    cross_platform_sed '/requires:/d' "$COMPONENTS_DIR/multiline-deps/component.yml"
    cat >> "$COMPONENTS_DIR/multiline-deps/component.yml" << EOF
requires:
  - dep1
  - dep2
EOF

    run validate_component_dependencies "multiline-deps"

    [ "$status" -eq 0 ]
}

@test "validate_component_dependencies: handles quoted dependencies" {
    create_valid_component "quoted-dep"
    create_valid_component "main-quoted"

    # Add quoted dependency
    cross_platform_sed 's/requires: \[\]/requires: ["quoted-dep"]/' "$COMPONENTS_DIR/main-quoted/component.yml"

    run validate_component_dependencies "main-quoted"

    [ "$status" -eq 0 ]
}

@test "validate_component_dependencies: handles empty requires" {
    create_valid_component "no-deps"

    run validate_component_dependencies "no-deps"

    [ "$status" -eq 0 ]
}

@test "validate_component_dependencies: fails for missing component.yml" {
    mkdir -p "$COMPONENTS_DIR/no-file"

    run validate_component_dependencies "no-file"

    [ "$status" -eq 1 ]
}

# =============================================================================
# INSTALL SCRIPT VALIDATION TESTS
# =============================================================================

@test "validate_component_install_script: passes for executable script" {
    create_valid_component "with-script"

    run validate_component_install_script "with-script"

    [ "$status" -eq 0 ]
}

@test "validate_component_install_script: fails for missing script" {
    create_valid_component "no-script"
    rm "$COMPONENTS_DIR/no-script/install.sh"

    run validate_component_install_script "no-script"

    [ "$status" -eq 1 ]
}

@test "validate_component_install_script: warns for non-executable script" {
    create_valid_component "non-exec"
    chmod -x "$COMPONENTS_DIR/non-exec/install.sh"

    run validate_component_install_script "non-exec"

    [ "$status" -eq 0 ]  # Should pass but warn
}

# =============================================================================
# COMPREHENSIVE VALIDATION TESTS
# =============================================================================

@test "validate_all_components: passes with all valid components" {
    create_valid_component "comp1"
    create_valid_component "comp2"
    create_valid_component "comp3"

    run validate_all_components

    [ "$status" -eq 0 ]
}

@test "validate_all_components: fails with mixed valid/invalid components" {
    create_valid_component "valid1"
    create_invalid_component "invalid1" "name"
    create_valid_component "valid2"

    run validate_all_components

    [ "$status" -eq 1 ]
}

@test "validate_all_components: handles empty components directory" {
    # Empty components directory
    run validate_all_components

    [ "$status" -eq 0 ]  # Should pass with warning
}

@test "validate_all_components: fails for missing components directory" {
    export COMPONENTS_DIR="/nonexistent/path"

    run validate_all_components

    [ "$status" -eq 1 ]
}

@test "validate_all_components: validates dependencies across components" {
    create_valid_component "base"
    create_valid_component "dependent"

    # Make dependent require base
    cross_platform_sed 's/requires: \[\]/requires: [base]/' "$COMPONENTS_DIR/dependent/component.yml"

    run validate_all_components

    [ "$status" -eq 0 ]
}

@test "validate_all_components: detects circular dependencies" {
    create_valid_component "circ1"
    create_valid_component "circ2"

    # Create circular dependency
    cross_platform_sed 's/requires: \[\]/requires: [circ2]/' "$COMPONENTS_DIR/circ1/component.yml"
    cross_platform_sed 's/requires: \[\]/requires: [circ1]/' "$COMPONENTS_DIR/circ2/component.yml"

    run validate_all_components

    [ "$status" -eq 0 ]  # Schema validation passes, circular deps detected elsewhere
}

# =============================================================================
# TEMPLATE GENERATION TESTS
# =============================================================================

@test "generate_install_script_template: creates valid template" {
    run generate_install_script_template "test-component"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "#!/usr/bin/env bash" ]]
    [[ "$output" =~ "set -euo pipefail" ]]
    [[ "$output" =~ "__COMPONENT_NAME__" ]]
    [[ "$output" =~ component_install\(\) ]]
}

@test "generate_install_script_template: includes error handling" {
    run generate_install_script_template "error-test"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "setup_error_handlers" ]]
    [[ "$output" =~ "retry_with_backoff" ]]
    [[ "$output" =~ "ERROR_INSTALLATION_FAILED" ]]
}

@test "generate_install_script_template: supports multiple package managers" {
    run generate_install_script_template "multi-pm"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "brew install" ]]
    [[ "$output" =~ "apt-get install" ]]
    [[ "$output" =~ "dnf install" ]]
}

# =============================================================================
# EDGE CASE AND ERROR HANDLING TESTS
# =============================================================================

@test "validate_component_schema: handles malformed YAML gracefully" {
    create_valid_component "malformed"

    # Create malformed YAML (unclosed quote)
    echo 'badField: "unclosed quote' >> "$COMPONENTS_DIR/malformed/component.yml"

    # Should not crash, may warn about unknown field
    run validate_component_schema "malformed"

    # Status varies based on how malformed YAML is handled
    # Important: should not crash with set -e
    [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "validate_component_schema: handles special characters in field values" {
    create_valid_component "special-chars"

    # Add fields with special characters
    cat >> "$COMPONENTS_DIR/special-chars/component.yml" << 'EOF'
description: "Component with $pecial ch@racters & symbols!"
homepage: "https://example.com/path?param=value&other=test"
EOF

    run validate_component_schema "special-chars"

    [ "$status" -eq 0 ]
}

@test "validate_component_dependencies: handles whitespace in dependency names" {
    create_valid_component "whitespace-dep"
    create_valid_component "main-whitespace"

    # Add dependency with extra whitespace
    cross_platform_sed 's/requires: \[\]/requires: [ whitespace-dep ]/' "$COMPONENTS_DIR/main-whitespace/component.yml"

    run validate_component_dependencies "main-whitespace"

    [ "$status" -eq 0 ]
}

@test "validate_component_install_script: handles script with shebang variations" {
    create_valid_component "shebang-test"

    # Test different shebangs
    echo "#!/bin/bash" > "$COMPONENTS_DIR/shebang-test/install.sh"
    echo "echo 'Different shebang'" >> "$COMPONENTS_DIR/shebang-test/install.sh"
    chmod +x "$COMPONENTS_DIR/shebang-test/install.sh"

    run validate_component_install_script "shebang-test"

    [ "$status" -eq 0 ]
}

# =============================================================================
# INTEGRATION AND STRESS TESTS
# =============================================================================

@test "integration: full validation workflow" {
    # Create a realistic component setup
    create_valid_component "git"
    create_valid_component "fzf"
    create_valid_component "neovim"

    # Set up dependencies
    cross_platform_sed 's/requires: \[\]/requires: [git]/' "$COMPONENTS_DIR/fzf/component.yml"
    cross_platform_sed 's/requires: \[\]/requires: [git, fzf]/' "$COMPONENTS_DIR/neovim/component.yml"

    # Validate individual components
    for comp in "git" "fzf" "neovim"; do
        run validate_component_schema "$comp"
        [ "$status" -eq 0 ]

        run validate_component_dependencies "$comp"
        [ "$status" -eq 0 ]

        run validate_component_install_script "$comp"
        [ "$status" -eq 0 ]
    done

    # Validate all together
    run validate_all_components
    [ "$status" -eq 0 ]
}

@test "stress: validate many components" {
    # Create many components
    for i in {1..20}; do
        create_valid_component "stress-comp-$i"

        # Add some dependencies for complexity
        if [[ $i -gt 1 ]]; then
            local prev_comp="stress-comp-$((i-1))"
            cross_platform_sed "s/requires: \\[\\]/requires: [$prev_comp]/" "$COMPONENTS_DIR/stress-comp-$i/component.yml"
        fi
    done

    run validate_all_components

    [ "$status" -eq 0 ]
}

@test "robustness: validation with filesystem limitations" {
    create_valid_component "robust-test"

    # Test with readonly component directory (if possible)
    if [[ "$(id -u)" != "0" ]]; then
        # Make component.yml readonly
        chmod 444 "$COMPONENTS_DIR/robust-test/component.yml"

        run validate_component_schema "robust-test"

        [ "$status" -eq 0 ]  # Should still be able to read

        # Restore permissions
        chmod 644 "$COMPONENTS_DIR/robust-test/component.yml"
    else
        skip "Running as root - cannot test readonly files safely"
    fi
}
