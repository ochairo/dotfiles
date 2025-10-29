#!/usr/bin/env bash
# env/debug.sh - environment debug summary

env_debug_info() {
  echo "Shell: $(env_shell)"
  echo "User: $(env_user)"
  echo "Home: $(env_home)"
  echo "Hostname: $(env_hostname)"
  echo "CPU Cores: $(env_cpu_cores)"
  echo "RAM (MB): $(env_ram_mb)"
  echo "CI: $(env_is_ci && echo yes || echo no)"
  echo "Docker: $(env_is_docker && echo yes || echo no)"
  echo "Root: $(env_is_root && echo yes || echo no)"
}
