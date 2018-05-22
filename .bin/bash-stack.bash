#!/usr/bin/env bash

# Bash Stack

set -o errtrace
set -o errexit
set -o nounset

declare -a stack

stack_push () {
    [ $# -eq 1 ] || _stack_err "stack_push takes one argument" || return 1
    stack[${#stack[@]}]="$1"
}
stack_pop () {
    index=$(_stack_index) || _stack_err "index out of range" || return 1
    unset stack[$index]
}
stack_get () {
    [ $# -ge 1 ] && item="$1" || item="0"
    index=$(_stack_index $item) || _stack_err "index out of range" || return 1
    echo ${stack[$index]}
}
stack_list () {
    echo ${stack[@]}
}
stack_size () {
    echo ${#stack[@]}
}

# internal:
_stack_index () {
    [ $# -ge 1 ] && index="$1" || index="0" || true
    [ "$index" -ge 0 ] && [ "$index" -lt ${#stack[@]} ] || return 1
    expr ${#stack[@]} - "$index" - 1 || true
}
_stack_err () {
    echo "Stack error: $@" 1>&2
    return 1
}
