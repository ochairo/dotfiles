#!/usr/bin/env bash
# os/version.sh - version strings

os_version() { local os; os=$(os_detect); case "$os" in macos) sw_vers -productVersion 2>/dev/null || echo unknown ;; linux) [[ -f /etc/os-release ]] && grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"' || echo unknown ;; *) echo unknown ;; esac }
