#!/usr/bin/env bash
# arrays/mutation.sh - Named array mutation operations (push/pop/shift/unshift)

# Add element to end (push)
# Args: array_name, element
array_push() { local array_name="$1" element="$2"; eval "${array_name}+=(\"$element\")"; }

# Remove and return last element (pop)
# Args: array_name
# Output: last element
array_pop() {
    local array_name="$1" length last_index
    eval "length=\${#${array_name}[@]}"
    [[ $length -eq 0 ]] && return 1
    last_index=$((length - 1))
    eval "printf '%s\\n' \"\${${array_name}[$last_index]}\""
    eval "unset \"${array_name}[$last_index]\""
}

# Remove and return first element (shift)
# Args: array_name
# Output: first element
array_shift() {
    local array_name="$1" length
    eval "length=\${#${array_name}[@]}"
    [[ $length -eq 0 ]] && return 1
    eval "printf '%s\\n' \"\${${array_name}[0]}\""
    eval "${array_name}=(\"\${${array_name}[@]:1}\")"
}

# Add element to beginning (unshift)
# Args: array_name, element
array_unshift() { local array_name="$1" element="$2"; eval "${array_name}=(\"$element\" \"\${${array_name}[@]}\")"; }
