#!/usr/bin/env bash
# packages.sh - Package manager detection and utilities
# Reusable across any shell script project (macOS and Linux compatible)

# Prevent double loading
[[ -n "${SYSTEM_PACKAGES_LOADED:-}" ]] && return 0
readonly SYSTEM_PACKAGES_LOADED=1

# Detect available package manager
# Returns: brew, apt, dnf, yum, pacman, zypper, apk, or unknown
# Example: pm=$(pkg_detect)
pkg_detect() {
    if command -v brew >/dev/null 2>&1; then
        echo "brew"
    elif command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v zypper >/dev/null 2>&1; then
        echo "zypper"
    elif command -v apk >/dev/null 2>&1; then
        echo "apk"
    else
        echo "unknown"
        return 1
    fi
}

# Check if a package manager is available
# Args: package_manager_name
# Returns: 0 if available, 1 otherwise
# Example: if pkg_exists "brew"; then echo "Homebrew installed"; fi
pkg_exists() {
    local pm="${1}"
    command -v "$pm" >/dev/null 2>&1
}

# Get package manager install command
# Args: package_manager_name (optional, auto-detects if not provided)
# Returns: install command (e.g., "brew install", "apt-get install")
# Example: install_cmd=$(pkg_install_cmd)
pkg_install_cmd() {
    local pm="${1:-$(pkg_detect)}"

    case "$pm" in
        "brew")
            echo "brew install"
            ;;
        "apt")
            echo "apt-get install -y"
            ;;
        "dnf")
            echo "dnf install -y"
            ;;
        "yum")
            echo "yum install -y"
            ;;
        "pacman")
            echo "pacman -S --noconfirm"
            ;;
        "zypper")
            echo "zypper install -y"
            ;;
        "apk")
            echo "apk add"
            ;;
        *)
            echo "unknown"
            return 1
            ;;
    esac
}

# Get package manager update command
# Args: package_manager_name (optional, auto-detects if not provided)
# Returns: update command
# Example: update_cmd=$(pkg_update_cmd)
pkg_update_cmd() {
    local pm="${1:-$(pkg_detect)}"

    case "$pm" in
        "brew")
            echo "brew update"
            ;;
        "apt")
            echo "apt-get update"
            ;;
        "dnf")
            echo "dnf check-update"
            ;;
        "yum")
            echo "yum check-update"
            ;;
        "pacman")
            echo "pacman -Sy"
            ;;
        "zypper")
            echo "zypper refresh"
            ;;
        "apk")
            echo "apk update"
            ;;
        *)
            echo "unknown"
            return 1
            ;;
    esac
}

# Get package manager upgrade command
# Args: package_manager_name (optional, auto-detects if not provided)
# Returns: upgrade command
# Example: upgrade_cmd=$(pkg_upgrade_cmd)
pkg_upgrade_cmd() {
    local pm="${1:-$(pkg_detect)}"

    case "$pm" in
        "brew")
            echo "brew upgrade"
            ;;
        "apt")
            echo "apt-get upgrade -y"
            ;;
        "dnf")
            echo "dnf upgrade -y"
            ;;
        "yum")
            echo "yum upgrade -y"
            ;;
        "pacman")
            echo "pacman -Syu --noconfirm"
            ;;
        "zypper")
            echo "zypper update -y"
            ;;
        "apk")
            echo "apk upgrade"
            ;;
        *)
            echo "unknown"
            return 1
            ;;
    esac
}

# Check if a package is installed
# Args: package_name, package_manager (optional)
# Returns: 0 if installed, 1 otherwise
# Example: if pkg_is_installed "git"; then echo "Git installed"; fi
pkg_is_installed() {
    local package="${1}"
    local pm="${2:-$(pkg_detect)}"

    case "$pm" in
        "brew")
            brew list "$package" >/dev/null 2>&1
            ;;
        "apt")
            dpkg -l "$package" 2>/dev/null | grep -q "^ii"
            ;;
        "dnf"|"yum")
            rpm -q "$package" >/dev/null 2>&1
            ;;
        "pacman")
            pacman -Q "$package" >/dev/null 2>&1
            ;;
        "zypper")
            zypper se -i "$package" | grep -q "^i"
            ;;
        "apk")
            apk info -e "$package" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# Get package manager name (user-friendly)
# Args: package_manager (optional, auto-detects if not provided)
# Returns: friendly name
# Example: name=$(pkg_name)
pkg_name() {
    local pm="${1:-$(pkg_detect)}"

    case "$pm" in
        "brew") echo "Homebrew" ;;
        "apt") echo "APT" ;;
        "dnf") echo "DNF" ;;
        "yum") echo "YUM" ;;
        "pacman") echo "Pacman" ;;
        "zypper") echo "Zypper" ;;
        "apk") echo "APK" ;;
        *) echo "Unknown" ;;
    esac
}

# Check if running with sudo/root privileges
# Returns: 0 if root, 1 otherwise
# Example: if pkg_is_root; then echo "Running as root"; fi
pkg_is_root() {
    [[ $EUID -eq 0 ]]
}

# Get sudo command prefix if needed
# Returns: "sudo" if not root and sudo available, empty otherwise
# Example: $(pkg_sudo) apt-get install git
pkg_sudo() {
    if pkg_is_root; then
        echo ""
    elif command -v sudo >/dev/null 2>&1; then
        echo "sudo"
    else
        echo ""
    fi
}
