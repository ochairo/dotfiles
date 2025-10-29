#!/usr/bin/env bash
# register/filter.sh - Tag filtering & aggregation
components_by_tag() { local tag="$1" comp tags; components_list | while read -r comp; do tags=$(components_tags "$comp"); [[ "$tags" == *"$tag"* ]] && echo "$comp"; done; }
components_all_tags() { local comp; components_list | while read -r comp; do components_tags "$comp" | tr ',' '\n'; done | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sort -u | grep -v '^$'; }
