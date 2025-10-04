#!/usr/bin/env bash
# usage: dot health [--only comp1,comp2]
# summary: Run health checks for components (use --only comp1,comp2 for specific ones)
# group: core
set -euo pipefail
# All constants and paths are now provided by the dot script via environment variables
# shellcheck disable=SC1091
source "$CORE_DIR/bootstrap.sh"
core_require log registry selection
# shellcheck disable=SC1091
source "$CORE_DIR/env.sh" 2>/dev/null || true

_ONLY=""
while [[ $# -gt 0 ]]; do
	case $1 in
	--only)
		_ONLY="$2"
		shift 2
		;;
	*)
		log_warn "Unknown flag $1"
		shift
		;;
	esac
done

# Precompute portable PATH and export
if command -v env_portable_path >/dev/null 2>&1; then
	_DOT_PORTABLE_PATH="$(env_portable_path)"
	export PATH="$_DOT_PORTABLE_PATH:$PATH"
fi

components=($(registry_list_components))
if [[ -n $_ONLY ]]; then
	IFS=',' read -r -a only_arr <<<"$_ONLY"
	components=()
	for c in "${only_arr[@]}"; do
		[[ -d "$ROOT/components/$c" ]] && components+=("$c") || log_warn "Unknown component $c"
	done
fi

passes=0
fails=0
for comp in "${components[@]}"; do
	hc=$(registry_health_check "$comp" || true)
	if [[ -z ${hc// /} ]]; then
		log_debug "No health check: $comp"
		continue
	fi
	log_info "Health: $comp => $hc"
	tmp=$(mktemp)
	printf '#!/usr/bin/env bash\nset -euo pipefail\nPATH=%q:$PATH\n(%s)\n' "${_DOT_PORTABLE_PATH:-}" "$hc" >"$tmp"
	chmod +x "$tmp"
	if "$tmp" 1>/dev/null 2>"$tmp.err"; then
		log_info "PASS $comp"
		passes=$((passes + 1))
	else
		rc=$?
		sample=$(head -c 400 "$tmp.err" || true)
		log_error "FAIL $comp rc=$rc cmd='$hc' stderr='${sample}'"
		fails=$((fails + 1))
	fi
	rm -f "$tmp" "$tmp.err" || true
done

log_info "Health summary: $passes passed, $fails failed"
[[ $fails -gt 0 ]] && exit 1 || exit 0
