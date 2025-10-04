#!/usr/bin/env bats

load 'test_helper'

setup() {
  TEST_ROOT="$BATS_TEST_TMPDIR/work"
  mkdir -p "$TEST_ROOT"
  export PATH="$(cd "$BATS_TEST_DIRNAME/../src/core" && pwd):$PATH"
  # shellcheck source=../src/core/log.sh
  source "$BATS_TEST_DIRNAME/../src/core/log.sh"
  # shellcheck source=../src/core/fs.sh
  source "$BATS_TEST_DIRNAME/../src/core/fs.sh"
}

@test 'fs_symlink creates new symlink' {
  mkdir -p "$TEST_ROOT/src"
  echo hi > "$TEST_ROOT/src/file"
  fs_symlink "$TEST_ROOT/src/file" "$TEST_ROOT/link"
  run readlink "$TEST_ROOT/link"
  [ "$status" -eq 0 ]
  [ "$output" = "$TEST_ROOT/src/file" ]
}

@test 'fs_symlink idempotent when already linked' {
  mkdir -p "$TEST_ROOT/src"
  touch "$TEST_ROOT/src/a"
  ln -s "$TEST_ROOT/src/a" "$TEST_ROOT/lnk"
  fs_symlink "$TEST_ROOT/src/a" "$TEST_ROOT/lnk"  # should not error
  run readlink "$TEST_ROOT/lnk"
  [ "$output" = "$TEST_ROOT/src/a" ]
}
