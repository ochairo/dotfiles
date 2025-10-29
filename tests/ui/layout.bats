#!/usr/bin/env bats
# layout.bats - tests for ui_layout_* capacity & parsing

setup() {
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
  source "$PROJECT_ROOT/src/lib/ui/index.sh"
}

@test "layout computes capacity without paging when filtered fits" {
  rows=40 fixed=2 spacer=1 top=0 footer=6 filtered=5 filter_mode=0
  metrics=$(ui_layout_compute_capacity "$rows" "$fixed" "$spacer" "$top" "$footer" "$filtered" "$filter_mode")
  # capacity should be >= filtered and need_paging=0
  cap=${metrics%%:*}; rest=${metrics#*:}; need=${rest%%:*}
  [ "$need" -eq 0 ]
  [ "$cap" -ge 5 ]
}

@test "layout computes paging when filtered exceeds capacity" {
  rows=20 fixed=2 spacer=1 top=0 footer=6 filtered=200 filter_mode=0
  metrics=$(ui_layout_compute_capacity "$rows" "$fixed" "$spacer" "$top" "$footer" "$filtered" "$filter_mode")
  cap=${metrics%%:*}; rest=${metrics#*:}; need=${rest%%:*}
  [ "$need" -eq 1 ]
}

@test "layout parse metrics returns expected key=value lines" {
  rows=25 fixed=2 spacer=1 top=0 footer=6 filtered=30 filter_mode=1
  metrics=$(ui_layout_compute_capacity "$rows" "$fixed" "$spacer" "$top" "$footer" "$filtered" "$filter_mode")
  kv=$(ui_layout_parse_metrics "$metrics")
  echo "$kv" | grep -q 'capacity='
  echo "$kv" | grep -q 'need_paging='
}
