#!/usr/bin/env bash
# packages/detect.sh - detection + helpers

pkg_detect() {
  if command -v brew >/dev/null 2>&1; then echo brew; elif command -v apt-get >/dev/null 2>&1; then echo apt; elif command -v dnf >/dev/null 2>&1; then echo dnf; elif command -v yum >/dev/null 2>&1; then echo yum; elif command -v pacman >/dev/null 2>&1; then echo pacman; elif command -v zypper >/dev/null 2>&1; then echo zypper; elif command -v apk >/dev/null 2>&1; then echo apk; else echo unknown; return 1; fi }
pkg_exists() { command -v "$1" >/dev/null 2>&1; }
pkg_name() { local pm="${1:-$(pkg_detect)}"; case "$pm" in brew)echo Homebrew;; apt)echo APT;; dnf)echo DNF;; yum)echo YUM;; pacman)echo Pacman;; zypper)echo Zypper;; apk)echo APK;; *)echo Unknown;; esac }
pkg_is_root() { [[ $EUID -eq 0 ]]; }
pkg_sudo() { if pkg_is_root; then echo ""; elif command -v sudo >/dev/null 2>&1; then echo sudo; else echo ""; fi }
