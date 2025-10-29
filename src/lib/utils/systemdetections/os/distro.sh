#!/usr/bin/env bash
# os/distro.sh - Linux distribution detection

os_linux_distro() {
  [[ "$(uname -s)" == Linux ]] || { echo not-linux; return 1; }
  if [[ -f /etc/os-release ]]; then
    local id; id=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    case "$id" in ubuntu)echo ubuntu;; debian)echo debian;; fedora)echo fedora;; rhel|centos)echo rhel;; arch)echo arch;; opensuse*)echo opensuse;; alpine)echo alpine;; *)echo unknown;; esac
  else echo unknown; fi
}
