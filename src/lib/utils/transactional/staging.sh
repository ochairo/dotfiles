#!/usr/bin/env bash
# transactional/staging.sh - staging file/dir/symlink/delete ops

tx_stage_file() {
    local src="$1" dest="$2"
    tx_is_enabled || { cp "$src" "$dest"; return; }
    local staged="${TX_DIR}/stage${dest}"; mkdir -p "$(dirname "$staged")"; cp "$src" "$staged"; tx_record "FILE" "$dest" "$src"
}

tx_stage_dir() {
    local src="$1" dest="$2"
    tx_is_enabled || { cp -r "$src" "$dest"; return; }
    local staged="${TX_DIR}/stage${dest}"; mkdir -p "$(dirname "$staged")"; cp -r "$src" "$staged"; tx_record "DIR" "$dest" "$src"
}

tx_stage_symlink() {
    local target="$1" link="$2"
    tx_is_enabled || { ln -sf "$target" "$link"; return; }
    local staged="${TX_DIR}/stage${link}"; mkdir -p "$(dirname "$staged")"; ln -sf "$target" "$staged"; tx_record "SYMLINK" "$link" "$target"
}

tx_stage_delete() {
    local path="$1"
    tx_is_enabled || { rm -rf "$path"; return; }
    if [[ -e "$path" ]]; then local backup="${TX_DIR}/backup${path}"; mkdir -p "$(dirname "$backup")"; cp -a "$path" "$backup"; tx_record "DELETE" "$path"; fi
}
