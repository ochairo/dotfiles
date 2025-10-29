#!/usr/bin/env bash
# validation/formats.sh - URL, email, IPv4, port, semver

validate_url() { local u="$1"; [[ $u == http://* || $u == https://* ]]; }
validate_email() { [[ "$1" =~ ^[[:alnum:]._-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}$ ]]; }
validate_ipv4() { local ip="$1"; [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1; local IFS='.'; read -ra o <<<"$ip"; for x in "${o[@]}"; do [[ $x -ge 0 && $x -le 255 ]] || return 1; done; }
validate_port() { local p="$1"; [[ $p =~ ^[1-9][0-9]*$ ]] || return 1; [[ $p -ge 1 && $p -le 65535 ]]; }
validate_semver() { [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; }
