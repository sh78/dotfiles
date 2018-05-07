#!/usr/bin/env bash

# XML prettifier
#
#   EXAMPLE: echo '<foo><bar>hello world</bar></foo>' | ./xml-prettify.bash
#

set -o errtrace
set -o errexit
set -o nounset

parent=$(dirname -- "$BASH_SOURCE")
source "$parent/bash-xml.bash"
source "$parent/bash-stack.bash"

xml_prettify_indent="2"
xml_prettify_print () {
    printf "%*s%s\n" $(expr $(stack_size) \* $xml_prettify_indent) "" "$1"
}

xml_prettify () {
    bash_xml_sax_parse xml_prettify_start xml_prettify_end xml_prettify_characters
}

xml_prettify_start () {
    case "$1" in
        *"/>") ;; # HACK: skip self terminating tags
        *) xml_prettify_print "$1" ;;
    esac
    stack_push "$2"
}
xml_prettify_end () {
    stack_pop
    xml_prettify_print "$1"
}
xml_prettify_characters () {
    xml_prettify_print "$1"
    return 0
}

if [ "$0" == "$BASH_SOURCE" ]; then
    xml_prettify
fi
