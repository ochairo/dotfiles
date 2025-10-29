#!/usr/bin/env bats
# tests/lib/msg.bats

load "../helpers/common.sh"

setup() {
  DOTFILES_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  export DOTFILES_ROOT
  source "$DOTFILES_ROOT/src/lib/index.sh"
}

@test "msg loader guard" {
  run bash -c "source '$DOTFILES_ROOT/src/lib/utilities/msg/msg.sh'; echo $MSG_MODULE_LOADED"
  [ "$status" -eq 0 ]
  [[ "$output" == "1" ]]
}

@test "msg_info emits text" { run msg_info "hello"; assert_success "$status"; assert_output_contains "$output" "hello"; }
@test "msg_error emits text" { run msg_error "boom"; assert_success "$status"; assert_output_contains "$output" "boom"; }
@test "msg_warn emits text" { run msg_warn "caution"; assert_success "$status"; assert_output_contains "$output" "caution"; }
@test "msg_success emits text" { run msg_success "done"; assert_success "$status"; assert_output_contains "$output" "done"; }
