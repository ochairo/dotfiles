#!/usr/bin/env bash
# os/platform.sh - platform combining os+distro

os_platform() { local os; os=$(os_detect); case "$os" in macos)echo macos;; linux)os_linux_distro;; *)echo unknown; return 1;; esac }
