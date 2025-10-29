#!/usr/bin/env bash
# packages/status.sh - installation status checks

pkg_is_installed() {
  local package="$1" pm="${2:-$(pkg_detect)}"
  case "$pm" in
    brew) brew list "$package" >/dev/null 2>&1 ;;
    apt) dpkg -l "$package" 2>/dev/null | grep -q "^ii" ;;
    dnf|yum) rpm -q "$package" >/dev/null 2>&1 ;;
    pacman) pacman -Q "$package" >/dev/null 2>&1 ;;
    zypper) zypper se -i "$package" | grep -q "^i" ;;
    apk) apk info -e "$package" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}
