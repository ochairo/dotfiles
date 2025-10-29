#!/usr/bin/env bash
# os/arch.sh - architecture detection

os_arch() { uname -m; }
os_is_arm() { local a; a=$(os_arch); [[ $a == arm64 || $a == aarch64 ]]; }
os_is_x86_64() { [[ $(os_arch) == x86_64 ]]; }
