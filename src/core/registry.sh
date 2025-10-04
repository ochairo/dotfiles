#!/usr/bin/env bash
# core/registry.sh - load component metadata (v1)
set -euo pipefail

source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/constants.sh"
source "$DOTFILES_ROOT/core/log.sh"

registry_components_dir() { echo "$COMPONENTS_DIR"; }

registry_list_components() {
	command ls "$COMPONENTS_DIR" 2>/dev/null | sort
}

registry_meta_path() { echo "$COMPONENTS_DIR/$1/component.yml"; }

registry_has_metadata() { [[ -f $(registry_meta_path "$1") ]]; }

registry_get_field() {
	local name=$1 field=$2
	local file
	file=$(registry_meta_path "$name")
	[[ -f $file ]] || return 1
	awk -F': *' -v k="$field" 'tolower($1)==tolower(k){sub(/^[^:]*:[[:space:]]*/, "");print;exit}' "$file"
}

registry_requires() {
	local name=$1
	local file=$(registry_meta_path "$name")
	[[ -f $file ]] || return 0
	# Support two forms:
	# requires: [a, b]
	# requires:\n#   [a, b]
	awk '
    tolower($0) ~ /^requires:/ {
      # if list starts on same line
      if ($0 ~ /\[/) { line=$0; sub(/^[^[]*\[/,"",line); sub(/].*$/, "", line); gsub(/,/ ," ", line); print line; exit }
      inlist=1; next
    }
    inlist==1 && /\[/ {
      line=$0; gsub(/\[/ ,"", line); gsub(/].*/, "", line); gsub(/,/ ," ", line); print line; exit
    }
  ' "$file" | tr ' ' '\n' | sed '/^$/d'
}

registry_parallel_safe() { [[ $(registry_get_field "$1" parallelSafe) == true* ]]; }
registry_is_critical() { [[ $(registry_get_field "$1" critical) == true* ]]; }

registry_health_check() {
	local raw
	raw=$(registry_get_field "$1" healthCheck || true)
	# Trim surrounding quotes (single or double) if present
	if [[ ${#raw} -ge 2 ]]; then
		case $raw in
		"\""*"\"") raw=${raw:1:-1} ;;
		"'"*"'") raw=${raw:1:-1} ;;
		esac
	fi
	printf '%s' "$raw"
}

registry_files() {
	local name=$1
	local file
	file=$(registry_meta_path "$name")
	[[ -f $file ]] || return 0
	# Extract files list from YAML
	grep -A 20 "^files:" "$file" 2>/dev/null | grep "^  -" | sed 's/^  - *//' || true
}

# Get package name for a specific package manager
registry_get_package_name() {
	local component=$1
	local pkg_manager=$2
	local file
	file=$(registry_meta_path "$component")
	[[ -f $file ]] || return 1

	# Try to get package name from packages.<pkg_manager>
	local package_name
	package_name=$(awk -F': *' -v pm="$pkg_manager" '
		/^packages:/ { in_packages=1; next }
		in_packages && /^  [a-z]/ {
			if ($1 == pm) {
				gsub(/^[[:space:]]*/, "", $1);
				print $2;
				exit
			}
		}
		/^[a-zA-Z]/ && in_packages { exit }
	' "$file" 2>/dev/null)

	# If no package mapping found, fall back to component name
	if [[ -z "$package_name" ]]; then
		package_name=$(registry_get_field "$component" name)
	fi

	echo "$package_name"
}
