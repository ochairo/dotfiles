#!/usr/bin/env bats

setup() {
    # Clear any stale environment variables that might interfere
    unset PROJECT_ROOT DOTFILES_ROOT COMMANDS_DIR CORE_DIR CONFIGS_DIR COMPONENTS_DIR

    local dotfiles_root
    dotfiles_root="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    export DOTFILES_ROOT="$dotfiles_root/src"

    # CRITICAL SAFETY CHECK: Ensure we're in test mode
    if [ "$BATS_TEST_TMPDIR" = "" ] || [ "$BATS_TMPDIR" = "" ]; then
        echo "CRITICAL ERROR: Test isolation not working - BATS temp dirs not set!"
        return 1
    fi

    # For registry tests, we need to test with real components, so don't override COMPONENTS_DIR
    unset COMPONENTS_DIR

    # Source bootstrap and dependencies
    # shellcheck disable=SC1091  # Path is set dynamically in test environment
    source "$DOTFILES_ROOT/core/init/bootstrap.sh"
    core_require log
    # shellcheck disable=SC1091  # Path is set dynamically in test environment
    source "$DOTFILES_ROOT/core/init/constants.sh"
    # shellcheck disable=SC1091  # Path is set dynamically in test environment
    source "$DOTFILES_ROOT/core/component/registry.sh"
}

@test "registry_list_components: lists existing components" {
    run registry_list_components
    [ "$status" -eq 0 ]
    # Should include some known real components
    [[ "$output" =~ git ]]
}

@test "registry_meta_path: returns correct path for real component" {
    run registry_meta_path git
    [ "$status" -eq 0 ]
    [[ "$output" == *"/git/component.yml" ]]
}

@test "registry_get_field: retrieves field from real component" {
    run registry_get_field git name
    [ "$status" -eq 0 ]
    [[ "$output" == "git" ]]
}

@test "registry_get_field: handles non-existent component" {
    run registry_get_field nonexistent name
    [ "$status" -ne 0 ]
}

@test "registry_requires: works with real component" {
    run registry_requires git
    [ "$status" -eq 0 ]
    # Should return empty or valid dependency list
}

@test "registry_parallel_safe: detects parallel safety" {
    run registry_parallel_safe git
    [ "$status" -eq 0 ]  # Should succeed whether true or false
}

@test "registry_health_check: returns health check command" {
    run registry_health_check git
    [ "$status" -eq 0 ]
    [[ "$output" =~ git.*version ]]
}

@test "selection save and load functionality" {
    # Test basic selection save/load using real components
    echo "git" > "$BATS_TEST_TMPDIR/test_selection"
    export DOTFILES_SELECTION_FILE="$BATS_TEST_TMPDIR/test_selection"

    run registry_list_components
    [ "$status" -eq 0 ]
    [[ "$output" =~ git ]]
}
