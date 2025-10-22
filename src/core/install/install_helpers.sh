#!/usr/bin/env bash
# Platform-specific component installation framework
# Follows SOLID principles for clean, maintainable installation logic

set -euo pipefail

# Source dependencies
# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/init/bootstrap.sh"
core_require log os error fs

# ==============================================================================
# PLATFORM DETECTION (Single Responsibility)
# ==============================================================================

# Detect current platform with specific OS/distribution detection
# Returns: macos, ubuntu, debian, fedora, rhel, centos, arch, opensuse, alpine
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

# ==============================================================================
# CONFIGURATION READING (Single Responsibility)
# ==============================================================================

# Read platform-specific field from component.yml (supports nested fields)
# Usage: read_platform_field <component_name> <platform> <field>
read_platform_field() {
    local component_name="$1"
    local platform="$2"
    local field="$3"
    local component_yml="${COMPONENTS_DIR:-$DOTFILES_ROOT/components}/$component_name/component.yml"

    if [[ ! -f "$component_yml" ]]; then
        return 1
    fi

    # Handle nested fields (e.g., repositorySetup.type)
    if [[ "$field" == *.* ]]; then
        local parent_field="${field%%.*}"
        local child_field="${field#*.}"

        # Extract nested field value
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
        ' "$component_yml"
    else
        # Handle simple fields (including multi-line YAML blocks with | or >)
        awk -v platform="$platform" -v field="$field" '
            /^platforms:/ { in_platforms = 1; next }
            in_platforms && /^[[:space:]]*'"$platform"':/ { in_platform = 1; next }
            in_platform && /^[[:space:]]*'"$field"':[[:space:]]*\|/ {
                # Found multi-line block scalar (|)
                in_multiline = 1
                # Get the indentation level of the first content line
                getline
                if (match($0, /^[[:space:]]*/)) {
                    indent = RLENGTH
                    print substr($0, indent + 1)
                }
                next
            }
            in_multiline && /^[[:space:]]*[a-z]+:/ {
                # Found next field, end multi-line
                in_multiline = 0
                in_platform = 0
                exit
            }
            in_multiline {
                # Continue printing multi-line content
                if (match($0, /^[[:space:]]*/)) {
                    if (RLENGTH >= indent) {
                        print substr($0, indent + 1)
                    } else {
                        # Indentation decreased, end of block
                        in_multiline = 0
                        in_platform = 0
                        exit
                    }
                }
                next
            }
            in_platform && /^[[:space:]]*[a-z]+:/ && !/^[[:space:]]*'"$field"':/ { in_platform = 0 }
            in_platform && /^[[:space:]]*'"$field"':/ {
                # Single-line field
                gsub(/^[[:space:]]*'"$field"':[[:space:]]*"?/, "")
                gsub(/"?[[:space:]]*$/, "")
                print
                exit
            }
            /^[a-zA-Z]/ && !/^platforms:/ { in_platforms = 0; in_platform = 0 }
        ' "$component_yml"
    fi
}

# Get platform configuration for component
# Usage: get_platform_config <component_name>
get_platform_config() {
    local component_name="$1"
    local current_platform

    current_platform=$(get_current_platform)

    # Check if platform is supported
    local component_yml="${DOTFILES_ROOT}/components/$component_name/component.yml"
    if [[ ! -f "$component_yml" ]]; then
        log_error "Component.yml not found for $component_name"
        return 1
    fi

    # Check if platform has configuration
    if ! grep -A 20 "^platforms:" "$component_yml" | grep -q "^[[:space:]]*$current_platform:"; then
        log_error "Platform $current_platform not supported by component $component_name"
        return 1
    fi

    echo "$current_platform"
}

# ==============================================================================
# REPOSITORY MANAGEMENT (Single Responsibility)
# ==============================================================================

# Setup repository based on configuration
# Usage: setup_repository <component_name> <platform>
setup_repository() {
    local component_name="$1"
    local platform="$2"
    local repo_type
    local key_url
    local repo_file
    local repo_config

    repo_type=$(read_platform_field "$component_name" "$platform" "repositorySetup.type")

    if [[ -z "$repo_type" ]]; then
        return 0  # No repository setup needed
    fi

    key_url=$(read_platform_field "$component_name" "$platform" "repositorySetup.keyUrl")
    repo_file=$(read_platform_field "$component_name" "$platform" "repositorySetup.repoFile")
    repo_config=$(read_platform_field "$component_name" "$platform" "repositorySetup.repoConfig")

    log_info "Setting up $repo_type repository for $component_name"

    # Import GPG key if provided
    if [[ -n "$key_url" ]]; then
        log_info "Importing GPG key from $key_url"
        sudo rpm --import "$key_url"
    fi

    # Create repository configuration file if provided
    if [[ -n "$repo_file" && -n "$repo_config" ]]; then
        log_info "Creating repository configuration at $repo_file"
        echo "$repo_config" | sudo tee "$repo_file" >/dev/null
    fi

    log_info "Repository setup completed successfully"
}

# ==============================================================================
# PACKAGE INSTALLATION (Single Responsibility)
# ==============================================================================

# Install package using specified package manager
# Usage: install_package <package_name> <package_manager>
install_package() {
    local package_name="$1"
    local package_manager="$2"

    log_info "Installing $package_name via $package_manager"

    case "$package_manager" in
        "brew")
            brew install "$package_name"
            ;;
        "brew-cask")
            brew install --cask "$package_name"
            ;;
        "apt")
            sudo apt-get update -y && sudo apt-get install -y "$package_name"
            ;;
        "dnf")
            sudo dnf install -y "$package_name"
            ;;
        "pacman")
            sudo pacman -S --noconfirm "$package_name"
            ;;
        "yay")
            yay -S --noconfirm "$package_name"
            ;;
        "paru")
            paru -S --noconfirm "$package_name"
            ;;
        "zypper")
            sudo zypper install -y "$package_name"
            ;;
        "snap")
            sudo snap install "$package_name"
            ;;
        "flatpak")
            flatpak install -y "$package_name"
            ;;
        "pip"|"pip3")
            "$package_manager" install --user "$package_name"
            ;;
        "npm")
            npm install -g "$package_name"
            ;;
        "yarn")
            yarn global add "$package_name"
            ;;
        "cargo")
            cargo install "$package_name"
            ;;
        "go")
            go install "$package_name"
            ;;
        "meta")
            log_info "Meta package $package_name - no direct installation needed (dependencies only)"
            ;;
        *)
            log_error "Unknown package manager: $package_manager"
            return 1
            ;;
    esac
}

# ==============================================================================
# INSTALLATION METHODS (Single Responsibility)
# ==============================================================================

# Install via package manager
# Usage: install_via_package <component_name> <platform>
install_via_package() {
    local component_name="$1"
    local platform="$2"
    local package_name
    local package_manager

    package_name=$(read_platform_field "$component_name" "$platform" "packageName")
    package_manager=$(read_platform_field "$component_name" "$platform" "packageManager")

    if [[ -z "$package_name" ]]; then
        log_error "packageName not specified for $component_name on $platform"
        return 1
    fi

    if [[ -z "$package_manager" ]]; then
        log_error "packageManager not specified for $component_name on $platform"
        return 1
    fi

    # Set up repository if configuration is provided
    setup_repository "$component_name" "$platform"

    # Install the package
    if ! install_package "$package_name" "$package_manager"; then
        log_warn "Primary installation method failed for $component_name"

        # Try fallback method if available
        local fallback_method
        fallback_method=$(read_platform_field "$component_name" "$platform" "fallbackMethod")

        if [[ -n "$fallback_method" ]]; then
            log_info "Attempting fallback installation method: $fallback_method"
            case "$fallback_method" in
                "script")
                    local fallback_script_url
                    fallback_script_url=$(read_platform_field "$component_name" "$platform" "fallbackScriptUrl")
                    if [[ -n "$fallback_script_url" ]]; then
                        log_info "Running fallback script: $fallback_script_url"
                        if curl -fsSL "$fallback_script_url" | bash; then
                            log_info "Fallback script installation succeeded"
                        else
                            log_error "Fallback script installation failed"
                            return 1
                        fi
                    else
                        log_error "fallbackScriptUrl not specified for fallback method"
                        return 1
                    fi
                    ;;
                "package")
                    local fallback_package_manager
                    local fallback_package_name
                    fallback_package_manager=$(read_platform_field "$component_name" "$platform" "fallbackPackageManager")
                    fallback_package_name=$(read_platform_field "$component_name" "$platform" "fallbackPackageName")
                    if [[ -n "$fallback_package_manager" && -n "$fallback_package_name" ]]; then
                        log_info "Trying fallback package: $fallback_package_name via $fallback_package_manager"
                        install_package "$fallback_package_name" "$fallback_package_manager" || return 1
                    else
                        log_error "Fallback package details not specified"
                        return 1
                    fi
                    ;;
                *)
                    log_error "Unsupported fallback method: $fallback_method"
                    return 1
                    ;;
            esac
        else
            log_error "No fallback method available for $component_name"
            return 1
        fi
    fi

    # Verify installation
    log_info "Verifying $component_name installation"
    if command -v "${package_name}" >/dev/null 2>&1 || command -v "${component_name}" >/dev/null 2>&1; then
        log_info "$component_name installed and verified successfully"
    else
        log_warn "$component_name installed but command not found in PATH"
    fi

    log_info "Successfully installed $component_name via package manager"
}

# Install via script download and execution
# Usage: install_via_script <component_name> <platform>
install_via_script() {
    local component_name="$1"
    local platform="$2"
    local script_url
    local script_args

    script_url=$(read_platform_field "$component_name" "$platform" "scriptUrl")
    script_args=$(read_platform_field "$component_name" "$platform" "scriptArgs")

    if [[ -z "$script_url" ]]; then
        log_error "scriptUrl not specified for $component_name on $platform"
        return 1
    fi

    log_info "Installing $component_name via script: $script_url"

    # Run pre-install commands if specified
    local pre_install
    pre_install=$(read_platform_field "$component_name" "$platform" "preInstall")
    if [[ -n "$pre_install" ]]; then
        log_info "Running pre-install commands for $component_name"
        eval "$pre_install"
    fi

    # Download and execute script
    if [[ -n "$script_args" ]]; then
        curl -fsSL "$script_url" | bash -s -- "$script_args"
    else
        curl -fsSL "$script_url" | bash
    fi

    # Run post-install commands if specified
    local post_install
    post_install=$(read_platform_field "$component_name" "$platform" "postInstall")
    if [[ -n "$post_install" ]]; then
        log_info "Running post-install commands for $component_name"
        eval "$post_install"
    fi

    log_info "Successfully installed $component_name via script"
}

# Install via git clone
# Usage: install_via_git <component_name> <platform>
install_via_git() {
    local component_name="$1"
    local platform="$2"
    local git_url
    local target_dir
    local depth
    local branch
    local build_command

    git_url=$(read_platform_field "$component_name" "$platform" "gitUrl")
    target_dir=$(read_platform_field "$component_name" "$platform" "targetDir")
    depth=$(read_platform_field "$component_name" "$platform" "depth")
    branch=$(read_platform_field "$component_name" "$platform" "branch")
    build_command=$(read_platform_field "$component_name" "$platform" "buildCommand")

    if [[ -z "$git_url" ]]; then
        log_error "gitUrl not specified for $component_name on $platform"
        return 1
    fi

    if [[ -z "$target_dir" ]]; then
        log_error "targetDir not specified for $component_name on $platform"
        return 1
    fi

    # Expand environment variables in target_dir
    target_dir=$(eval echo "$target_dir")

    log_info "Installing $component_name via git clone to $target_dir"

    # Run pre-install commands if specified
    local pre_install
    pre_install=$(read_platform_field "$component_name" "$platform" "preInstall")
    if [[ -n "$pre_install" ]]; then
        log_info "Running pre-install commands for $component_name"
        eval "$pre_install"
    fi

    # Create parent directory
    mkdir -p "$(dirname "$target_dir")"

    # Clone repository
    local git_cmd="git clone"
    if [[ -n "$depth" ]]; then
        git_cmd="$git_cmd --depth $depth"
    fi
    if [[ -n "$branch" ]]; then
        git_cmd="$git_cmd --branch $branch"
    fi
    git_cmd="$git_cmd '$git_url' '$target_dir'"

    eval "$git_cmd"

    # Run build command if specified
    if [[ -n "$build_command" ]]; then
        log_info "Running build command for $component_name"
        (cd "$target_dir" && eval "$build_command")
    fi

    # Run post-install commands if specified
    local post_install
    post_install=$(read_platform_field "$component_name" "$platform" "postInstall")
    if [[ -n "$post_install" ]]; then
        log_info "Running post-install commands for $component_name"
        eval "$post_install"
    fi

    log_info "Successfully installed $component_name via git"
}

# Install via binary download
# Usage: install_via_binary <component_name> <platform>
install_via_binary() {
    local component_name="$1"
    local platform="$2"
    local download_url
    local target_dir
    local extract_path
    local make_executable

    download_url=$(read_platform_field "$component_name" "$platform" "downloadUrl")
    target_dir=$(read_platform_field "$component_name" "$platform" "targetDir")
    extract_path=$(read_platform_field "$component_name" "$platform" "extractPath")
    make_executable=$(read_platform_field "$component_name" "$platform" "makeExecutable")

    if [[ -z "$download_url" ]]; then
        log_error "downloadUrl not specified for $component_name on $platform"
        return 1
    fi

    if [[ -z "$target_dir" ]]; then
        log_error "targetDir not specified for $component_name on $platform"
        return 1
    fi

    # Expand environment variables in target_dir
    target_dir=$(eval echo "$target_dir")

    log_info "Installing $component_name via binary download from $download_url"

    # Run pre-install commands if specified
    local pre_install
    pre_install=$(read_platform_field "$component_name" "$platform" "preInstall")
    if [[ -n "$pre_install" ]]; then
        log_info "Running pre-install commands for $component_name"
        eval "$pre_install"
    fi

    # Create target directory
    mkdir -p "$target_dir"

    # Download and extract
    local temp_file
    temp_file=$(mktemp)
    curl -fsSL "$download_url" -o "$temp_file"

    if [[ -n "$extract_path" ]]; then
        # Extract specific file from archive
        if [[ "$download_url" =~ \.tar\.gz$ ]] || [[ "$download_url" =~ \.tgz$ ]]; then
            tar -xzf "$temp_file" -C "$target_dir" "$extract_path" --strip-components=1
        elif [[ "$download_url" =~ \.zip$ ]]; then
            unzip -j "$temp_file" "$extract_path" -d "$target_dir"
        else
            log_error "Unsupported archive format for $download_url"
            return 1
        fi
    else
        # Direct binary download
        local filename
        filename=$(basename "$download_url")
        cp "$temp_file" "$target_dir/$filename"

        if [[ "$make_executable" == "true" ]]; then
            chmod +x "$target_dir/$filename"
        fi
    fi

    rm -f "$temp_file"

    # Run post-install commands if specified
    local post_install
    post_install=$(read_platform_field "$component_name" "$platform" "postInstall")
    if [[ -n "$post_install" ]]; then
        log_info "Running post-install commands for $component_name"
        eval "$post_install"
    fi

    log_info "Successfully installed $component_name via binary download"
}

# ==============================================================================
# MAIN INSTALLATION ORCHESTRATOR (Open/Closed Principle)
# ==============================================================================

# Install a component using platform-specific configuration
# Usage: install_component <component_name>
install_component() {
    local component_name="$1"
    local platform
    local install_method

    # Get platform configuration
    if ! platform=$(get_platform_config "$component_name"); then
        return 1
    fi

    # Get installation method for this platform
    install_method=$(read_platform_field "$component_name" "$platform" "installMethod")

    if [[ -z "$install_method" ]]; then
        log_error "installMethod not specified for $component_name on $platform"
        return 1
    fi

    log_info "Installing $component_name on $platform using method: $install_method"

    # Run pre-install commands if specified
    local pre_install
    pre_install=$(read_platform_field "$component_name" "$platform" "preInstall")
    if [[ -n "$pre_install" ]]; then
        log_info "Running pre-install commands for $component_name"
        if ! eval "$pre_install"; then
            log_error "Pre-install commands failed for $component_name"
            return 1
        fi
    fi

    # Delegate to appropriate installation method
    local install_result=0
    case "$install_method" in
        "package")
            install_via_package "$component_name" "$platform" || install_result=$?
            ;;
        "script")
            install_via_script "$component_name" "$platform" || install_result=$?
            ;;
        "git")
            install_via_git "$component_name" "$platform" || install_result=$?
            ;;
        "binary")
            install_via_binary "$component_name" "$platform" || install_result=$?
            ;;
        *)
            log_error "Unknown installation method: $install_method"
            return 1
            ;;
    esac

    # Check if main installation succeeded
    if [[ $install_result -ne 0 ]]; then
        log_error "Installation failed for $component_name"
        return $install_result
    fi

    # Run post-install commands if specified
    local post_install
    post_install=$(read_platform_field "$component_name" "$platform" "postInstall")
    if [[ -n "$post_install" ]]; then
        log_info "Running post-install commands for $component_name"
        # Execute multi-line scripts with bash, passing necessary environment variables
        # Export DOTFILES_ROOT and other required paths for the subshell
        if ! DOTFILES_ROOT="${DOTFILES_ROOT}" \
             CORE_DIR="${CORE_DIR}" \
             COMPONENTS_DIR="${COMPONENTS_DIR}" \
             bash -c "$post_install"; then
            log_warn "Post-install commands failed for $component_name (but installation was successful)"
        fi
    fi

    log_info "Successfully completed installation of $component_name"
    return 0
}

# ==============================================================================
# VALIDATION AND HEALTH CHECKS (Single Responsibility)
# ==============================================================================

# Check if component is already installed
# Usage: is_component_installed <component_name>
is_component_installed() {
    local component_name="$1"
    local platform
    local install_method
    local package_name
    local command_name

    # Get platform configuration
    if ! platform=$(get_platform_config "$component_name"); then
        return 1
    fi

    install_method=$(read_platform_field "$component_name" "$platform" "installMethod")

    case "$install_method" in
        "package")
            # Check if command exists or package is installed
            command_name=$(read_platform_field "$component_name" "$platform" "commandName")
            package_name=$(read_platform_field "$component_name" "$platform" "packageName")

            # First try command check
            if [[ -n "$command_name" ]] && command -v "$command_name" >/dev/null 2>&1; then
                return 0
            fi

            # Fallback to package manager specific checks
            local package_manager
            package_manager=$(read_platform_field "$component_name" "$platform" "packageManager")

            case "$package_manager" in
                "brew")
                    brew list "$package_name" >/dev/null 2>&1
                    ;;
                "brew-cask")
                    brew list --cask "$package_name" >/dev/null 2>&1
                    ;;
                "apt")
                    dpkg -l "$package_name" 2>/dev/null | grep -q "^ii"
                    ;;
                "dnf")
                    dnf list installed "$package_name" >/dev/null 2>&1
                    ;;
                "pacman")
                    pacman -Q "$package_name" >/dev/null 2>&1
                    ;;
                *)
                    # Default to command check
                    command -v "${command_name:-$component_name}" >/dev/null 2>&1
                    ;;
            esac
            ;;
        "git")
            local target_dir
            target_dir=$(read_platform_field "$component_name" "$platform" "targetDir")
            target_dir=$(eval echo "$target_dir")
            [[ -d "$target_dir" ]]
            ;;
        "binary")
            local target_dir
            target_dir=$(read_platform_field "$component_name" "$platform" "targetDir")
            target_dir=$(eval echo "$target_dir")
            [[ -d "$target_dir" ]] && [[ -n "$(ls -A "$target_dir" 2>/dev/null)" ]]
            ;;
        "script")
            # Check if command exists (scripts usually install commands)
            command_name=$(read_platform_field "$component_name" "$platform" "commandName")
            command -v "${command_name:-$component_name}" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# List supported platforms for a component
# Usage: list_supported_platforms <component_name>
list_supported_platforms() {
    local component_name="$1"
    local component_yml="${DOTFILES_ROOT}/components/$component_name/component.yml"

    if [[ ! -f "$component_yml" ]]; then
        log_error "Component.yml not found for $component_name"
        return 1
    fi

    # Extract platform names from YAML
    awk '/^platforms:/ { in_platforms = 1; next }
         in_platforms && /^[[:space:]]*[a-z]+:/ {
             match($0, /^[[:space:]]*([a-z]+):/, arr)
             if (arr[1]) print arr[1]
         }
         /^[a-zA-Z]/ && !/^platforms:/ { in_platforms = 0 }' "$component_yml"
}

# ==============================================================================
# REPOSITORY UPDATE UTILITIES (formerly update.sh)
# ==============================================================================

# Get current repository branch
update_repo_branch() {
	if git -C "$DOTFILES_ROOT" rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
		git -C "$DOTFILES_ROOT" rev-parse --abbrev-ref HEAD
	else
		echo main
	fi
}

# Get current repository revision
update_current_ref() {
	git -C "$DOTFILES_ROOT" rev-parse --short HEAD 2>/dev/null || true
}

# Get remote repository revision
update_remote_ref() {
	local branch
	branch=$(update_repo_branch)
	git -C "$DOTFILES_ROOT" fetch --quiet origin "$branch" || true
	git -C "$DOTFILES_ROOT" rev-parse --short "origin/$branch" 2>/dev/null || true
}

# Check if repository is up-to-date
update_state() {
	local cur remote
	cur=$(update_current_ref)
	remote=$(update_remote_ref)
	if [[ -z $cur || -z $remote ]]; then
		echo unknown
		return 0
	fi
	if [[ $cur == $remote ]]; then echo up-to-date; else echo out-of-date; fi
}

# Pull latest changes from remote
update_pull() {
	local branch
	branch=$(update_repo_branch)
	git -C "$DOTFILES_ROOT" pull --ff-only origin "$branch"
}
