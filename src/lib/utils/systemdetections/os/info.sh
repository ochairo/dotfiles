#!/usr/bin/env bash
# os/info.sh - consolidated OS info

os_info() { local os platform version arch; os=$(os_detect); platform=$(os_platform); version=$(os_version); arch=$(os_arch); echo "OS: $os"; echo "Platform: $platform"; echo "Version: $version"; echo "Architecture: $arch"; }
