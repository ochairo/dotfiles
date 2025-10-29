#!/usr/bin/env bash
# env/system.sh - cpu & memory

env_cpu_cores() { if [[ "$(uname -s)" == Darwin ]]; then sysctl -n hw.ncpu 2>/dev/null || echo 1; else nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || echo 1; fi }
env_ram_mb() { if [[ "$(uname -s)" == Darwin ]]; then local bytes; bytes=$(sysctl -n hw.memsize 2>/dev/null || echo 0); echo $((bytes/1024/1024)); else local kb; kb=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}' || echo 0); echo $((kb/1024)); fi }
