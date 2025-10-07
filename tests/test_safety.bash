#!/usr/bin/env bash
# Shared test safety functions to prevent corruption of source code

# CRITICAL: Verify test isolation - prevent tests from writing to real source code
verify_test_isolation() {
    local components_dir="${COMPONENTS_DIR:-}"
    local test_components_dir="${TEST_COMPONENTS_DIR:-}"

    # Check COMPONENTS_DIR
    if [[ -n "$components_dir" && "$components_dir" == *"/src/components"* ]]; then
        echo "FATAL ERROR: Test attempted to use real components directory!" >&2
        echo "COMPONENTS_DIR=$components_dir" >&2
        echo "This would corrupt source code. Tests must use temporary directories only." >&2
        exit 1
    fi

    # Check TEST_COMPONENTS_DIR
    if [[ -n "$test_components_dir" && "$test_components_dir" == *"/src/components"* ]]; then
        echo "FATAL ERROR: Test attempted to use real components directory!" >&2
        echo "TEST_COMPONENTS_DIR=$test_components_dir" >&2
        echo "This would corrupt source code. Tests must use temporary directories only." >&2
        exit 1
    fi

    # Verify we're using temporary directories
    if [[ -n "$components_dir" && "$components_dir" != *"/tmp/"* && "$components_dir" != */tmp/* ]]; then
        echo "WARNING: COMPONENTS_DIR is not in a temporary directory: $components_dir" >&2
    fi

    if [[ -n "$test_components_dir" && "$test_components_dir" != *"/tmp/"* && "$test_components_dir" != */tmp/* ]]; then
        echo "WARNING: TEST_COMPONENTS_DIR is not in a temporary directory: $test_components_dir" >&2
    fi
}

# Call this function in setup() for all tests that set component directories
enforce_test_isolation() {
    verify_test_isolation

    # Also check that we don't accidentally export to real components
    if env | grep -q "COMPONENTS_DIR.*src/components"; then
        echo "FATAL ERROR: Environment contains real components directory!" >&2
        env | grep "COMPONENTS_DIR"
        exit 1
    fi
}
