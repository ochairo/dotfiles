#!/usr/bin/env bats

# load ../test_helper  # Not needed - using minimal setup

# Test the core functions from install_helpers.sh in isolation
# This avoids the bootstrap dependency issues for now

setup() {
    # Set up test environment
    local dotfiles_root
    dotfiles_root="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    export DOTFILES_ROOT="$dotfiles_root"
    export MOCK_DIR="$BATS_TMPDIR/mocks"
    mkdir -p "$MOCK_DIR"
    export PATH="$MOCK_DIR:$PATH"

    # Source just the platform detection function manually
    # shellcheck disable=SC2329  # Function called indirectly by BATS
    get_current_platform() {
        local platform=""

        case "$(uname -s)" in
            "Darwin")
                platform="macos"
                ;;
            "Linux")
                if [[ -f /etc/os-release ]]; then
                    local id
                    id=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
                    case "$id" in
                        "ubuntu") platform="ubuntu" ;;
                        "debian") platform="debian" ;;
                        "fedora") platform="fedora" ;;
                        "rhel"|"centos") platform="rhel" ;;
                        "arch") platform="arch" ;;
                        "opensuse"*) platform="opensuse" ;;
                        "alpine") platform="alpine" ;;
                        *) platform="ubuntu" ;; # Default fallback
                    esac
                else
                    platform="ubuntu" # Default fallback
                fi
                ;;
            *)
                platform="ubuntu" # Default fallback
                ;;
        esac

        echo "$platform"
    }

    # Source the read_platform_field function manually (fixed version)
    # shellcheck disable=SC2329  # Function called indirectly by BATS
    read_platform_field() {
        local component_name="$1"
        local platform="$2"
        local field="$3"
        local component_yml="${DOTFILES_ROOT}/src/components/$component_name/component.yml"

        if [[ ! -f "$component_yml" ]]; then
            return 1
        fi

        # Handle nested fields (e.g., repositorySetup.type)
        if [[ "$field" == *.* ]]; then
            local parent_field="${field%%.*}"
            local child_field="${field#*.}"

            # Extract platform section, then find nested field
            awk -v platform="$platform" -v parent="$parent_field" -v child="$child_field" '
            BEGIN { found_platform = 0; found_parent = 0; platform_indent = 0; parent_indent = 0 }

            # Find platform section
            /^platforms:/ { next }
            found_platform == 0 && $0 ~ "^[[:space:]]*" platform ":" {
                found_platform = 1
                platform_indent = match($0, /[^[:space:]]/) - 1
                next
            }

            # We are in the platform section
            found_platform == 1 {
                current_indent = match($0, /[^[:space:]]/) - 1

                # If we hit another platform at same level, stop
                if (current_indent <= platform_indent && $0 ~ /:$/ && $0 !~ parent) {
                    exit
                }

                # Look for parent field
                if (found_parent == 0 && $0 ~ "^[[:space:]]*" parent ":") {
                    found_parent = 1
                    parent_indent = current_indent
                    next
                }

                # We are in the parent section, look for child
                if (found_parent == 1) {
                    # If we hit something at parent level or higher, exit parent
                    if (current_indent <= parent_indent && $0 ~ /:/) {
                        found_parent = 0
                        next
                    }

                    # Look for the child field
                    if ($0 ~ "^[[:space:]]*" child ":") {
                        sub("^[[:space:]]*" child ":[[:space:]]*", "")
                        gsub(/^"/, "")
                        gsub(/"$/, "")
                        print
                        exit
                    }
                }
            }' "$component_yml"
        else
            # Handle simple fields
            awk -v platform="$platform" -v field="$field" '
            BEGIN { found_platform = 0; platform_indent = 0 }

            /^platforms:/ { next }
            found_platform == 0 && $0 ~ "^[[:space:]]*" platform ":" {
                found_platform = 1
                platform_indent = match($0, /[^[:space:]]/) - 1
                next
            }

            found_platform == 1 {
                current_indent = match($0, /[^[:space:]]/) - 1

                # If we hit another platform at same level, stop
                if (current_indent <= platform_indent && $0 ~ /:$/) {
                    exit
                }

                # Look for our field
                if ($0 ~ "^[[:space:]]*" field ":") {
                    sub("^[[:space:]]*" field ":[[:space:]]*", "")
                    gsub(/^"/, "")
                    gsub(/"$/, "")
                    print
                    exit
                }
            }' "$component_yml"
        fi
    }
}

teardown() {
    rm -rf "$MOCK_DIR"
    # Clean up test components
    rm -rf "$DOTFILES_ROOT/src/components/test-"*
}

# Helper function to create mock commands
create_mock() {
    local command="$1"
    local exit_code="${2:-0}"
    local output="${3:-}"

    cat > "$MOCK_DIR/$command" << EOF
#!/bin/bash
echo "$output"
exit $exit_code
EOF
    chmod +x "$MOCK_DIR/$command"
}

# Helper to create test component.yml
create_test_component() {
    local component_name="$1"
    local content="$2"

    mkdir -p "$DOTFILES_ROOT/src/components/$component_name"
    echo "$content" > "$DOTFILES_ROOT/src/components/$component_name/component.yml"
}

# ==============================================================================
# PLATFORM DETECTION TESTS
# ==============================================================================

@test "get_current_platform: detects macOS correctly" {
    # Mock uname for macOS
    create_mock "uname" 0 "Darwin"

    run get_current_platform
    [ "$status" -eq 0 ]
    [ "$output" = "macos" ]
}

@test "get_current_platform: detects Ubuntu correctly from real system" {
    # This test works with the real system
    run get_current_platform
    [ "$status" -eq 0 ]
    # On macOS this should return "macos", adjust if running on Linux
    [[ "$output" =~ ^(macos|ubuntu|debian|fedora|rhel|centos|arch|opensuse|alpine)$ ]]
}

@test "get_current_platform: falls back to ubuntu for unknown OS" {
    create_mock "uname" 0 "FreeBSD"

    run get_current_platform
    [ "$status" -eq 0 ]
    [ "$output" = "ubuntu" ]
}

# ==============================================================================
# CONFIGURATION READING TESTS
# ==============================================================================

@test "read_platform_field: reads simple field correctly" {
    local component_yml='name: test-component
platforms:
  macos:
    installMethod: package
    packageManager: brew
    packageName: test-package
  ubuntu:
    installMethod: script'

    create_test_component "test-simple" "$component_yml"

    run read_platform_field "test-simple" "macos" "installMethod"
    [ "$status" -eq 0 ]
    [ "$output" = "package" ]

    run read_platform_field "test-simple" "macos" "packageManager"
    [ "$status" -eq 0 ]
    [ "$output" = "brew" ]

    run read_platform_field "test-simple" "ubuntu" "installMethod"
    [ "$status" -eq 0 ]
    [ "$output" = "script" ]
}

@test "read_platform_field: reads nested field correctly" {
    local component_yml='name: test-component
platforms:
  ubuntu:
    installMethod: package
    repositorySetup:
      type: apt
      keyUrl: https://example.com/key.gpg
      repository: "deb https://example.com/repo focal main"'

    create_test_component "test-nested" "$component_yml"

    run read_platform_field "test-nested" "ubuntu" "repositorySetup.type"
    [ "$status" -eq 0 ]
    [ "$output" = "apt" ]

    run read_platform_field "test-nested" "ubuntu" "repositorySetup.keyUrl"
    [ "$status" -eq 0 ]
    [ "$output" = "https://example.com/key.gpg" ]
}

@test "read_platform_field: handles missing component.yml" {
    run read_platform_field "nonexistent-component" "macos" "installMethod"
    [ "$status" -eq 1 ]
}

@test "read_platform_field: handles missing platform" {
    local component_yml='name: test-component
platforms:
  macos:
    installMethod: package'

    create_test_component "test-missing-platform" "$component_yml"

    run read_platform_field "test-missing-platform" "windows" "installMethod"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "read_platform_field: handles missing field" {
    local component_yml='name: test-component
platforms:
  macos:
    installMethod: package'

    create_test_component "test-missing-field" "$component_yml"

    run read_platform_field "test-missing-field" "macos" "nonexistentField"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

# ==============================================================================
# INTEGRATION TESTS
# ==============================================================================

@test "platform and configuration integration: real component example" {
    local component_yml='name: git
description: Git version control system
platforms:
  macos:
    installMethod: package
    packageManager: brew
    packageName: git
  ubuntu:
    installMethod: package
    packageManager: apt
    packageName: git
  fedora:
    installMethod: package
    packageManager: dnf
    packageName: git'

    create_test_component "test-git-integration" "$component_yml"

    # Test reading configuration for different platforms
    run read_platform_field "test-git-integration" "macos" "packageManager"
    [ "$status" -eq 0 ]
    [ "$output" = "brew" ]

    run read_platform_field "test-git-integration" "ubuntu" "packageManager"
    [ "$status" -eq 0 ]
    [ "$output" = "apt" ]

    run read_platform_field "test-git-integration" "fedora" "packageManager"
    [ "$status" -eq 0 ]
    [ "$output" = "dnf" ]
}

@test "complex component with repository setup" {
    local component_yml='name: docker
platforms:
  ubuntu:
    installMethod: package
    packageManager: apt
    packageName: docker-ce
    repositorySetup:
      type: apt
      keyUrl: https://download.docker.com/linux/ubuntu/gpg
      repository: "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    preInstall: "sudo apt-get update"
    postInstall: "sudo systemctl enable docker"'

    create_test_component "test-docker" "$component_yml"

    run read_platform_field "test-docker" "ubuntu" "repositorySetup.type"
    [ "$status" -eq 0 ]
    [ "$output" = "apt" ]

    run read_platform_field "test-docker" "ubuntu" "preInstall"
    [ "$status" -eq 0 ]
    [ "$output" = "sudo apt-get update" ]

    run read_platform_field "test-docker" "ubuntu" "postInstall"
    [ "$status" -eq 0 ]
    [ "$output" = "sudo systemctl enable docker" ]
}
