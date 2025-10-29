#!/usr/bin/env bats
# options.bats - tests for ui_option_format and ui_options_render

setup() {
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
  source "$PROJECT_ROOT/src/lib/ui/index.sh"
  options=("alpha - first" "beta - second")
  filtered_indices=(0 1)
  selected_status=(1 0)
  cursor=0
}

@test "ui_option_format shows checked checkbox for selected" {
  run ui_option_format 0 0
  echo "$output" | grep -q "☑"
}

@test "ui_option_format shows unchecked checkbox for unselected" {
  run ui_option_format 1 1
  echo "$output" | grep -q "☐"
}

@test "ui_options_render emits two lines for two items" {
  start_idx=0; end_idx=2
  output_lines=$(ui_options_render 2>&1 >/dev/null | wc -l | tr -d ' ')
  [ "$output_lines" -eq 2 ]
}
