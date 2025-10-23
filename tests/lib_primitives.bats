#!/usr/bin/env bats
# Tests for src2/lib/primitives/

setup() {
  # Load the library
  export DOTFILES_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  export SRC_DIR="$DOTFILES_ROOT/src"
  export LIB_DIR="$SRC_DIR/lib"

  # shellcheck source=../src/lib/index.sh
  source "$LIB_DIR/index.sh"
}# =============================================================================
# msg.sh tests
# =============================================================================

@test "msg_info prints info message" {
  run msg_info "test message"
  [ "$status" -eq 0 ]
  [[ "$output" == *"test message"* ]]
}

@test "msg_success prints success message" {
  run msg_success "success test"
  [ "$status" -eq 0 ]
  [[ "$output" == *"success test"* ]]
}

@test "msg_warn prints warning message" {
  run msg_warn "warning test"
  [ "$status" -eq 0 ]
  [[ "$output" == *"warning test"* ]]
}

@test "msg_error prints error message" {
  run msg_error "error test"
  [ "$status" -eq 0 ]
  [[ "$output" == *"error test"* ]]
}

# =============================================================================
# arrays.sh tests
# =============================================================================

@test "array_contains finds element in array" {
  local arr=("apple" "banana" "cherry")
  run array_contains arr "banana"
  [ "$status" -eq 0 ]
}

@test "array_contains returns 1 when element not found" {
  local arr=("apple" "banana" "cherry")
  run array_contains arr "orange"
  [ "$status" -eq 1 ]
}

@test "array_join joins array with delimiter" {
  local arr=("one" "two" "three")
  result=$(array_join arr ",")
  [ "$result" = "one,two,three" ]
}

# =============================================================================
# strings.sh tests
# =============================================================================

@test "string_trim removes leading/trailing whitespace" {
  result=$(string_trim "  hello world  ")
  [ "$result" = "hello world" ]
}

@test "string_lower converts to lowercase" {
  result=$(string_lower "HELLO WORLD")
  [ "$result" = "hello world" ]
}

@test "string_upper converts to uppercase" {
  result=$(string_upper "hello world")
  [ "$result" = "HELLO WORLD" ]
}

@test "string_contains checks substring" {
  run string_contains "hello world" "world"
  [ "$status" -eq 0 ]
}

# =============================================================================
# validation.sh tests
# =============================================================================

@test "validate_not_empty accepts non-empty string" {
  run validate_not_empty "test"
  [ "$status" -eq 0 ]
}

@test "validate_not_empty rejects empty string" {
  run validate_not_empty ""
  [ "$status" -eq 1 ]
}

@test "validate_email accepts valid email" {
  run validate_email "test@example.com"
  [ "$status" -eq 0 ]
}

@test "validate_email rejects invalid email" {
  run validate_email "invalid.email"
  [ "$status" -eq 1 ]
}

# =============================================================================
# files.sh tests
# =============================================================================

@test "file_exists detects existing file" {
  # Create temp file
  temp_file="$BATS_TMPDIR/test_file_$$"
  touch "$temp_file"

  run file_exists "$temp_file"
  [ "$status" -eq 0 ]

  # Cleanup
  rm -f "$temp_file"
}

@test "file_exists returns 1 for non-existent file" {
  run file_exists "/nonexistent/path/file.txt"
  [ "$status" -eq 1 ]
}

@test "file_is_readable checks file permissions" {
  temp_file="$BATS_TMPDIR/readable_test_$$"
  touch "$temp_file"
  chmod 644 "$temp_file"

  run file_is_readable "$temp_file"
  [ "$status" -eq 0 ]

  rm -f "$temp_file"
}
