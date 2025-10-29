#!/usr/bin/env bash
# pagination.sh - Pure pagination helpers (renamed from ui_pagination.sh)
ui_pages_total() { local count=${1:-0} size=${2:-1}; ((size<=0)) && size=1; local pages=$(((count + size - 1)/ size)); ((pages==0)) && pages=1; echo "$pages"; }
ui_page_bounds() { local page=${1:-0} size=${2:-1} count=${3:-0}; ((size<=0)) && size=1; local start=$((page*size)); ((start>count)) && start=$count; local end=$((start+size)); ((end>count)) && end=$count; echo "$start $end"; }
ui_page_clamp() { local req=${1:-0} size=${2:-1} count=${3:-0}; local pages; pages=$(ui_pages_total "$count" "$size"); ((req<0)) && req=0; ((req>=pages)) && req=$((pages-1)); echo "$req"; }
ui_recompute_page_size() { local count=${1:-0} footer=${2:-0} h_base=${3:-2} h_paged=${4:-4} min_rows=${5:-3} term size; term=$(tput lines 2>/dev/null || echo 24); size=$((term - h_base - footer)); ((size < min_rows)) && size=$min_rows; if (( count > size )); then size=$((term - h_paged - footer)); ((size < min_rows)) && size=$min_rows; fi; echo "$size"; }
export -f ui_pages_total ui_page_bounds ui_page_clamp ui_recompute_page_size
