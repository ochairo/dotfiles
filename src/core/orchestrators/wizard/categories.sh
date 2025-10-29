#!/usr/bin/env bash
# wizard/categories.sh - Category listing helpers

categories_count_total() { components_list | wc -l | tr -d ' '; }

categories_list() {
    local -a tags=() comp comp_tags comp_tag_array tag
    while IFS= read -r comp; do
        comp_tags=$(components_tags "$comp" 2>/dev/null || echo "")
        if [[ -n $comp_tags ]]; then
            IFS=',' read -ra comp_tag_array <<<"$comp_tags"
            for tag in "${comp_tag_array[@]}"; do
                tag=$(echo "$tag" | xargs)
                [[ -n $tag ]] && tags+=("$tag")
            done
        fi
    done < <(components_list)
    printf '%s\n' "${tags[@]}" | sort -u
}
