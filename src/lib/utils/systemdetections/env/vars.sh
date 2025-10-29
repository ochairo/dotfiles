#!/usr/bin/env bash
# env/vars.sh - variable presence & defaults

env_is_set() { local var="$1"; [[ -n "${!var:-}" ]]; }
env_get() { local var="$1" def="${2:-}"; echo "${!var:-$def}"; }
env_set_default() { local var="$1" val="$2"; [[ -z "${!var:-}" ]] && export "$var=$val"; }
