#!/usr/bin/env bats
# footer.bats - tests for ui_footer_lines and ui_footer_render

setup() {
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
  source "$PROJECT_ROOT/src/lib/ui/index.sh"
  # Minimal multiselect state simulation
  options=(alpha beta)
  selected_status=(0 0)
  total=${#options[@]}
  filtered_indices=(0 1)
  page_size=10
  filter_mode=0
}

@test "footer lines normal mode" {
  lines=$(ui_footer_lines "$filter_mode")
  [ "$lines" -eq 10 ]
}

@test "footer lines filter mode" {
  filter_mode=1
  lines=$(ui_footer_lines "$filter_mode")
  [ "$lines" -eq 6 ]
}
