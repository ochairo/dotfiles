#!/usr/bin/env bats
# error.bats - tests for ui_error_render

setup() {
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
  source "$PROJECT_ROOT/src/lib/ui/index.sh"
  # Provide minimal multiselect globals expected by helpers
  options=(a b c)
  filtered_indices=(0 1 2)
  selected_status=(0 0 0)
  filter_mode=0
  UI_FIXED_HEADER_COUNT=2
  UI_FIXED_HEADER_SPACER=1
  UI_FIXED_HEADER_TOP_PAD=0
}

@test "error render emits 3 lines when capacity below min" {
  # Force small rows to trigger error path
  stub_rows() { echo 5; }
  ui_layout_get_rows() { stub_rows; }
  run ui_error_render
  [ "$status" -eq 0 ]
  # Count stderr lines
  line_count=$(echo "$output" | wc -l | tr -d ' ')
  [ "$line_count" -eq 3 ]
}
