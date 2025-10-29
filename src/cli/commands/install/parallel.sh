#!/usr/bin/env bash
# parallel.sh - Parallel batch generation & execution for install

# Generate batches (legacy expected name generate_parallel_batches was missing).
# Current strategy: single batch containing all components. Future: smart grouping.
generate_parallel_batches() {
  local items=("$@")
  [[ ${#items[@]} -eq 0 ]] && return 0
  printf '1:%s\n' "${items[*]}"
}

install_parallel_batches() {
  local ordered=("$@") batches
  mapfile -t batches < <(generate_parallel_batches "${ordered[@]}")
  echo "${batches[@]}"
}

install_parallel_exec() {
  local batches=("$@") fail=0 batch_line batch_num batch_components rc
  for batch_line in "${batches[@]}"; do
    batch_num="${batch_line%%:*}"
    batch_components="${batch_line#*:}"
    msg_info "Executing batch $batch_num with components: $batch_components"
    for comp in $batch_components; do
      if ! run_component_serial "$comp"; then
        rc=$?
        [[ $rc -eq 2 ]] && { fail=1; break 2; }
      fi
    done
  done
  return $fail
}

export -f generate_parallel_batches install_parallel_batches install_parallel_exec
