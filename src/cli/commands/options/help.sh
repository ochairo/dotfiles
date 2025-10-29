#!/usr/bin/env bash
# usage: dot help [command]
# summary: Show all commands or detailed info for one command
# group: core
set -euo pipefail

TARGET="${1:-}" || true

if [[ -z "$TARGET" ]]; then
  echo "dot <command> [args...]" >&2
  echo "" >&2
  echo "Commands:" >&2
  echo "" >&2
  echo "  Main Commands:" >&2
  for cmd_file in "$COMMANDS_DIR"/*.sh; do
    [[ -f "$cmd_file" ]] || continue
    name="$(basename "$cmd_file" .sh)"
    summary="$(grep -E '^# summary:' "$cmd_file" | head -1 | sed 's/# summary:[[:space:]]*//' || true)"
    printf "    %-18s %s\n" "$name" "$summary" >&2
  done
  list_group() {
    local dir="$1" label="$2"
    local files=()
    while IFS= read -r -d '' f; do files+=("$f"); done < <(find "$dir" -type f -name '*.sh' -print0 | sort -z)
    [[ ${#files[@]} -eq 0 ]] && return 0
    echo "" >&2
    echo "  $label:" >&2
    for f in "${files[@]}"; do
      local name summary
      name="$(basename "$f" .sh)"
      summary="$(grep -E '^# summary:' "$f" | head -1 | sed 's/# summary:[[:space:]]*//' || true)"
      printf "    %-18s %s\n" "$name" "$summary" >&2
    done
  }
  list_group "$COMMANDS_DIR/component" "Components"
  list_group "$COMMANDS_DIR/doctor" "Doctor"
  list_group "$COMMANDS_DIR/maintenance" "Maintenance"
  echo "" >&2
  echo "Use 'dot help <command>' for details." >&2
  exit 0
fi

cmd_file=""
if [[ -f "$COMMANDS_DIR/$TARGET.sh" ]]; then
  cmd_file="$COMMANDS_DIR/$TARGET.sh"
else
  for subdir in "$COMMANDS_DIR"/*; do
    [[ -d "$subdir" ]] || continue
    candidate="$subdir/$TARGET.sh"
    if [[ -f "$candidate" ]]; then cmd_file="$candidate"; break; fi
  done
fi

if [[ -z "$cmd_file" ]]; then
  msg_error "Unknown command: $TARGET"
  exit 1
fi
awk '/^# usage:/{print substr($0,3)} /^# summary:/{print substr($0,3)} /^# aliases:/{print substr($0,3)}' "$cmd_file"
# Show options section if present in file comments
opts=$(grep -E '^# options:' "$cmd_file" | sed 's/# options:[[:space:]]*//') || true
if [[ -n ${opts// /} ]]; then
  echo ""; echo "Options:"; printf "%s\n" "$opts"
fi

echo ""; echo "Source: $(echo "$cmd_file" | sed "s|$PROJECT_ROOT/||")"
