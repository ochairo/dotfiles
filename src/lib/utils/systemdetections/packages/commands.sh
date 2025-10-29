#!/usr/bin/env bash
# packages/commands.sh - install/update/upgrade commands

pkg_install_cmd() { local pm="${1:-$(pkg_detect)}"; case "$pm" in brew)echo "brew install";; apt)echo "apt-get install -y";; dnf)echo "dnf install -y";; yum)echo "yum install -y";; pacman)echo "pacman -S --noconfirm";; zypper)echo "zypper install -y";; apk)echo "apk add";; *)echo unknown; return 1;; esac }
pkg_update_cmd() { local pm="${1:-$(pkg_detect)}"; case "$pm" in brew)echo "brew update";; apt)echo "apt-get update";; dnf)echo "dnf check-update";; yum)echo "yum check-update";; pacman)echo "pacman -Sy";; zypper)echo "zypper refresh";; apk)echo "apk update";; *)echo unknown; return 1;; esac }
pkg_upgrade_cmd() { local pm="${1:-$(pkg_detect)}"; case "$pm" in brew)echo "brew upgrade";; apt)echo "apt-get upgrade -y";; dnf)echo "dnf upgrade -y";; yum)echo "yum upgrade -y";; pacman)echo "pacman -Syu --noconfirm";; zypper)echo "zypper update -y";; apk)echo "apk upgrade";; *)echo unknown; return 1;; esac }
