#!/usr/bin/env bash
# os/detect.sh - base OS detection

os_detect() { case "$(uname -s)" in Darwin)echo macos;; Linux)echo linux;; *)echo unknown; return 1;; esac }
