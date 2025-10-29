#!/usr/bin/env bats
# header.bats - tests for ui_header_render and ui_header_lines

setup() {
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
  source "$PROJECT_ROOT/src/lib/ui/index.sh"
}

@test "header lines without paging or filter" {
  filtered_count=5 page_size=10 filter_mode=0
  lines=$(ui_header_lines "$filter_mode" "$page_size" "$filtered_count")
  [ "$lines" -eq 2 ]
}

@test "header lines with paging adds 2 lines" {
  filtered_count=50 page_size=10 filter_mode=0
  lines=$(ui_header_lines "$filter_mode" "$page_size" "$filtered_count")
  [ "$lines" -eq 4 ]
}

@test "header lines with filter adds 2 extra" {
  filtered_count=5 page_size=10 filter_mode=1
  lines=$(ui_header_lines "$filter_mode" "$page_size" "$filtered_count")
  [ "$lines" -eq 4 ]
}
