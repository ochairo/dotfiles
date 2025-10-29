#!/usr/bin/env bash
# env/ci.sh - CI & container detection

env_is_ci() { [[ -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" || -n "${GITLAB_CI:-}" || -n "${CIRCLECI:-}" || -n "${TRAVIS:-}" || -n "${JENKINS_HOME:-}" ]]; }
env_is_docker() { [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null; }
