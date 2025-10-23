#!/usr/bin/env bash
# os.sh - Operating system detection and information
# Reusable across any shell script project (macOS and Linux compatible)

# Prevent double loading
[[ -n "${SYSTEM_OS_LOADED:-}" ]] && return 0
readonly SYSTEM_OS_LOADED=1

# Detect current operating system
# Returns: macos, linux
# Example: os=$(os_detect)
os_detect() {
    case "$(uname -s)" in
        "Darwin")
            echo "macos"
            ;;
        "Linux")
            echo "linux"
            ;;
        *)
            echo "unknown"
            return 1
            ;;
    esac
}

# Detect Linux distribution
# Returns: ubuntu, debian, fedora, rhel, centos, arch, opensuse, alpine, unknown
# Example: distro=$(os_linux_distro)
os_linux_distro() {
    if [[ "$(uname -s)" != "Linux" ]]; then
        echo "not-linux"
        return 1
    fi

    if [[ -f /etc/os-release ]]; then
        local id
        id=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
        case "$id" in
            "ubuntu") echo "ubuntu" ;;
            "debian") echo "debian" ;;
            "fedora") echo "fedora" ;;
            "rhel"|"centos") echo "rhel" ;;
            "arch") echo "arch" ;;
            "opensuse"*) echo "opensuse" ;;
            "alpine") echo "alpine" ;;
            *) echo "unknown" ;;
        esac
    else
        echo "unknown"
    fi
}

# Detect platform (combines OS + distro for Linux)
# Returns: macos, ubuntu, debian, fedora, rhel, arch, opensuse, alpine
# Example: platform=$(os_platform)
os_platform() {
    local os
    os=$(os_detect)

    case "$os" in
        "macos")
            echo "macos"
            ;;
        "linux")
            os_linux_distro
            ;;
        *)
            echo "unknown"
            return 1
            ;;
    esac
}

# Check if running on macOS
# Returns: 0 if macOS, 1 otherwise
# Example: if os_is_macos; then echo "On Mac"; fi
os_is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

# Check if running on Linux
# Returns: 0 if Linux, 1 otherwise
# Example: if os_is_linux; then echo "On Linux"; fi
os_is_linux() {
    [[ "$(uname -s)" == "Linux" ]]
}

# Get OS version
# Returns: version string (e.g., "14.1.1" for macOS, "22.04" for Ubuntu)
# Example: version=$(os_version)
os_version() {
    local os
    os=$(os_detect)

    case "$os" in
        "macos")
            sw_vers -productVersion 2>/dev/null || echo "unknown"
            ;;
        "linux")
            if [[ -f /etc/os-release ]]; then
                grep "^VERSION_ID=" /etc/os-release | cut -d= -f2 | tr -d '"'
            else
                echo "unknown"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Get architecture
# Returns: x86_64, arm64, aarch64, etc.
# Example: arch=$(os_arch)
os_arch() {
    uname -m
}

# Check if running on ARM (Apple Silicon, ARM Linux)
# Returns: 0 if ARM, 1 otherwise
# Example: if os_is_arm; then echo "ARM CPU"; fi
os_is_arm() {
    local arch
    arch=$(os_arch)
    [[ "$arch" == "arm64" || "$arch" == "aarch64" ]]
}

# Check if running on x86_64
# Returns: 0 if x86_64, 1 otherwise
# Example: if os_is_x86_64; then echo "x86 CPU"; fi
os_is_x86_64() {
    [[ "$(os_arch)" == "x86_64" ]]
}

# Get full OS information as JSON-like string
# Returns: Multi-line OS info
# Example: os_info
os_info() {
    local os platform version arch
    os=$(os_detect)
    platform=$(os_platform)
    version=$(os_version)
    arch=$(os_arch)

    echo "OS: $os"
    echo "Platform: $platform"
    echo "Version: $version"
    echo "Architecture: $arch"
}
