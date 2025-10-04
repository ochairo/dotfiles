#!/usr/bin/env bash
# usage: dot install [--repeat] [--only <comp,...>] [--dry-run] [--dry-run-verbose] [--parallel]
# summary: Install/configure components (use --only comp1,comp2 for specific ones)
# group: core

set -euo pipefail
# All constants and paths are now provided by the dot script via environment variables
# ROOT points to src/ directory, PROJECT_ROOT points to project root
# shellcheck disable=SC1091
source "$CORE_DIR/bootstrap.sh"
core_require log registry selection fs parallel transactional
# shellcheck disable=SC1091
source "$CORE_DIR/env.sh" 2>/dev/null || true

# Precompute a portable PATH once (macOS + Linux) to avoid per-health variance
_DOT_PORTABLE_PATH=""
if command -v env_portable_path >/dev/null 2>&1; then
	_DOT_PORTABLE_PATH="$(env_portable_path)"
fi
if [[ -n $_DOT_PORTABLE_PATH ]]; then
	export PATH="$_DOT_PORTABLE_PATH:$PATH"
	log_debug "Global portable PATH applied: $_DOT_PORTABLE_PATH"
fi

DRY_RUN=0
DRY_RUN_VERBOSE=0
REPEAT=0
ONLY_LIST=""
USE_PARALLEL=0
declare -A _TIMINGS
_INSTALL_START_EPOCH=$(date +%s)

while [[ $# -gt 0 ]]; do
	case $1 in
	--dry-run)
		DRY_RUN=1
		shift
		;;
	--dry-run-verbose)
		DRY_RUN=1
		DRY_RUN_VERBOSE=1
		shift
		;;
	--repeat)
		REPEAT=1
		shift
		;;
	--only)
		ONLY_LIST="$2"
		shift 2
		;;
	--parallel)
		USE_PARALLEL=1
		shift
		;;
	*)
		log_warn "Unknown flag $1"
		shift
		;;
	esac
done

mapfile -t all_components < <(registry_list_components)

# Optional phase weighting to get a more semantic baseline order before dependency expansion.
# Lower weight installs earlier. Absent tag defaults to 500.
declare -A _PHASE_WEIGHTS=(
	[core]=10
	[shell]=20
	[appearance]=25
	[ui]=30
	[terminal]=35
	["terminal-mux"]=36
	[development]=50
	[python]=55
	[ruby]=55
	[node]=55
	[go]=55
	[rust]=55
	[ml]=60
	[editor]=70
)

weight_for_component() {
	local c=$1 meta priority tags w=500
	meta="$COMPONENTS_DIR/$c/component.yml"
	if [[ -f $meta ]]; then
		# Check priority field first (lower number = higher priority = earlier installation)
		priority=$(awk -F': *' 'tolower($1)=="priority"{print $2}' "$meta" 2>/dev/null || true)
		if [[ -n $priority && $priority =~ ^[0-9]+$ ]]; then
			w=$((priority * 10)) # Scale priority: 1 -> 10, 2 -> 20, etc.
		else
			# Fallback to tags for components without priority
			tags=$(awk -F': *' 'tolower($1)=="tags"{gsub(/\[/,"",$2);gsub(/\]/,"",$2);print tolower($2)}' "$meta" 2>/dev/null || true)
			if [[ -n ${tags// /} ]]; then
				IFS=',' read -r -a arr <<<"$tags"
				for t in "${arr[@]}"; do
					t=${t// /}
					[[ -n $t && -n ${_PHASE_WEIGHTS[$t]:-} ]] && { [[ ${_PHASE_WEIGHTS[$t]} -lt $w ]] && w=${_PHASE_WEIGHTS[$t]}; }
				done
			fi
		fi
	fi
	echo "$w"
}

sort_by_phase() {
	local items=("$@")
	for c in "${items[@]}"; do
		printf "%05d %s\n" "$(weight_for_component "$c")" "$c"
	done | sort -n | awk '{print $2}'
}
filtered=()

if [[ -n $ONLY_LIST ]]; then
	IFS=',' read -r -a reqs <<<"$ONLY_LIST"
	for c in "${reqs[@]}"; do
		if [[ -d "$COMPONENTS_DIR/$c" ]]; then filtered+=("$c"); else log_warn "Unknown component $c (skipped)"; fi
	done
elif [[ $REPEAT == 1 ]]; then
	sel=$(selection_load || true)
	if [[ -n $sel ]]; then
		for c in $sel; do
			if [[ -d "$COMPONENTS_DIR/$c" ]]; then
				filtered+=("$c")
			else
				log_warn "Component in selection not found: $c"
			fi
		done
	fi
fi

if [[ ${#filtered[@]} -eq 0 ]]; then
	filtered=("${all_components[@]}")
fi

# Apply phase sorting before dependency expansion
mapfile -t filtered < <(sort_by_phase "${filtered[@]}")

# Simple dependency expansion (no cycle detection in scaffold)
expand_deps() {
	local seen="$1"
	shift
	local out=()
	for c in "$@"; do
		if [[ ":$seen:" == *":$c:"* ]]; then continue; fi
		mapfile -t reqs < <(registry_requires "$c" || true)
		if [[ ${#reqs[@]} -gt 0 ]]; then
			mapfile -t temp_deps < <(expand_deps "$seen:$c" "${reqs[@]}")
			out+=("${temp_deps[@]}")
		fi
		out+=("$c")
	done
	printf '%s\n' "${out[@]}"
}

mapfile -t ordered < <(expand_deps "" "${filtered[@]}" | awk '!x[$0]++')

log_info "Planned install order: ${ordered[*]}"
[[ $DRY_RUN == 1 ]] && {
	if [[ $DRY_RUN_VERBOSE == 1 ]]; then
		echo ""
		log_info "$SYMBOL_DRY_RUN Verbose dry-run: showing what each component would do..."
		echo ""

		for component in "${ordered[@]}"; do
			echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
			echo "$SYMBOL_INSTALL Component: $component"

			# Show component info
			comp_file="$COMPONENTS_DIR/$component/component.yml"
			if [[ -f "$comp_file" ]]; then
				description=$(grep "^description:" "$comp_file" 2>/dev/null | sed 's/description: *//' || echo "No description available")
				tags=$(grep "^tags:" "$comp_file" 2>/dev/null | sed 's/tags: *//' || echo "[]")
				critical=$(grep "^critical:" "$comp_file" 2>/dev/null | sed 's/critical: *//' || echo "false")

				echo "  Description: $description"
				echo "  Tags: $tags"
				echo "  Critical: $critical"
			fi

			# Show health check
			health_check=$(registry_health_check "$component" 2>/dev/null || echo "No health check")
			echo "  Health Check: $health_check"

			# Show files that would be linked
			files=$(registry_files "$component" 2>/dev/null || true)
			if [[ -z "$files" ]]; then
				# Fallback: extract files directly from YAML
				files=$(grep -A 10 "^files:" "$comp_file" 2>/dev/null | grep "^  -" | sed 's/^  - *//' || true)
			fi
			if [[ -n "$files" ]]; then
				echo "  $SYMBOL_LINK Files to be symlinked:"
				echo "$files" | while read -r file; do
					[[ -n "$file" ]] && echo "    → $file"
				done
			fi

			# Show what the install script would do (first few lines for preview)
			install_script="$COMPONENTS_DIR/$component/install.sh"
			if [[ -f "$install_script" ]]; then
				echo "  $SYMBOL_RUN Install actions preview:"
				# Extract key installation steps from the script
				grep -E "(brew install|apt-get install|dnf install|pip install|npm install|log_info)" "$install_script" 2>/dev/null |
					head -5 | sed 's/^/    │ /' || echo "    │ Custom installation logic"
			fi
			echo ""
		done
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
		echo ""
		log_info "$SYMBOL_DRY_RUN Verbose dry-run complete. Total components: ${#ordered[@]}"
	else
		log_info "Dry run: exiting before execution (use --dry-run-verbose for detailed preview)"
	fi
	selection_save "${ordered[*]}"
	exit 0
}

if [[ ${DOTFILES_TRANSACTIONAL:-0} == 1 ]]; then
	log_info "Transactional mode enabled"
	transaction_begin || {
		log_error "Failed to begin transaction"
		exit 1
	}
fi

fail=0
declare -A _HEALTH_STATUS
_HEALTH_PASSES=0
_HEALTH_FAILS=0
run_component_serial() {
	local comp=$1
	local script="$COMPONENTS_DIR/$comp/install.sh"
	if [[ -f $script ]]; then
		# Ensure script is executable (some newly added components may lack +x)
		chmod +x "$script" 2>/dev/null || true
		log_info "== Installing $comp =="
		local _c_start
		_c_start=$(date +%s)
		if ! bash "$script"; then
			log_error "Component failed: $comp"
			if registry_is_critical "$comp"; then return 2; fi
		fi
		# Post-install health check (if declared)
		local hc
		hc=$(registry_health_check "$comp" || true)
		if [[ -n ${hc// /} ]]; then
			log_debug "Health check for $comp: $hc"
			# Use already-exported global PATH; avoid extra bash -c quoting issues by writing temp script
			local tmp
			tmp=$(mktemp)
			printf '#!/usr/bin/env bash\nset -euo pipefail\nPATH=%s\n(%s)\n' "${_DOT_PORTABLE_PATH:+${_DOT_PORTABLE_PATH}:}${PATH}" "$hc" >"$tmp"
			chmod +x "$tmp"
			local stderr_file
			stderr_file=$(mktemp)
			if ! "$tmp" 1>/dev/null 2>"$stderr_file"; then
				local hc_rc=$?
				local err_sample
				err_sample=$(head -c 500 "$stderr_file" 2>/dev/null || true)
				log_debug "Health failed ($comp) rc=$hc_rc cmd='$hc' PATH_START=\"${PATH%%:*}\" STDERR=\"${err_sample}\""
				_HEALTH_STATUS[$comp]=fail
				_HEALTH_FAILS=$((_HEALTH_FAILS + 1))
				if registry_is_critical "$comp"; then
					log_error "Health check failed (critical): $comp"
					rm -f "$tmp" "$stderr_file" || true
					return 2
				else
					log_warn "Health check failed (non-critical): $comp (continuing)"
				fi
			else
				_HEALTH_STATUS[$comp]=pass
				_HEALTH_PASSES=$((_HEALTH_PASSES + 1))
				log_info "Health check passed: $comp"
			fi
			rm -f "$tmp" "$stderr_file" || true
		fi
		local _c_end=$(date +%s)
		_TIMINGS[$comp]=$((_c_end - _c_start))
	else
		log_warn "No installer for $comp (skipping)"
	fi
}

if [[ $USE_PARALLEL == 1 ]]; then
	log_info "Parallel install enabled (workers=${DOT_PARALLEL_WORKERS:-4})"
	# Fallback: simple serial run for now (parallel implementation placeholder integration)
	for comp in "${ordered[@]}"; do
		if ! run_component_serial "$comp"; then
			rc=$?
			[[ $rc -eq 2 ]] && {
				fail=1
				break
			}
		fi
	done
else
	for comp in "${ordered[@]}"; do
		if ! run_component_serial "$comp"; then
			rc=$?
			[[ $rc -eq 2 ]] && {
				fail=1
				break
			}
		fi
	done
fi

if [[ ${DOTFILES_TRANSACTIONAL:-0} == 1 ]]; then
	if [[ $fail == 1 ]]; then
		log_warn "Aborting transaction due to failure"
		transaction_rollback || true
	else
		transaction_commit || {
			log_error "Transaction commit failed"
			exit 1
		}
	fi
fi

selection_save "${ordered[*]}"
[[ $fail == 1 ]] && {
	log_error "Critical component failure"
	exit 1
}
_INSTALL_TOTAL=$(($(date +%s) - _INSTALL_START_EPOCH))
log_info "Install complete in ${_INSTALL_TOTAL}s"

# Write timing JSON
{
	printf '{"totalSeconds":%s,"components":{' "$_INSTALL_TOTAL"
	i=0
	for k in "${!_TIMINGS[@]}"; do
		[[ $i -gt 0 ]] && printf ','
		printf '"%s":%s' "$k" "${_TIMINGS[$k]}"
		i=$((i + 1))
	done
	printf '}}\n'
} >"$DOTFILES_ROOT/state/install-timing.json" 2>/dev/null || true
log_debug "Timing written to state/install-timing.json"

# Health summary (if any health checks executed)
if [[ -v _HEALTH_STATUS && ${#_HEALTH_STATUS[@]} -gt 0 ]]; then
	log_info "Health summary: ${_HEALTH_PASSES} passed, ${_HEALTH_FAILS} failed"
	if [[ $_HEALTH_FAILS -gt 0 ]]; then
		failed_list=()
		for c in "${!_HEALTH_STATUS[@]}"; do
			if [[ ${_HEALTH_STATUS[$c]} == fail ]]; then failed_list+=("$c"); fi
		done
		IFS=','
		log_warn "Health failures: ${failed_list[*]}"
		unset IFS
	fi
fi
