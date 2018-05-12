#!/usr/bin/env bash

# Bash XML parser (SAX)
#
#   EXAMPLE: echo '<foo><bar>hello world</bar></foo>' | ./bash-xml.bash 'echo START:' 'echo END:' 'echo TEXT:'
#

set -o errtrace
set -o errexit
set -o nounset

bash_xml_sax_parse () {
    handle_element_start="$1"
    handle_element_end="$2"
    handle_characters="$3"
    # assumes each line contains one element
    cat "/dev/stdin" | bash_xml_split | while read line; do
        case "$line" in
            "<?"*)      ;;
            "</"*)      [ -z "$handle_element_end" ]    || $handle_element_end      "$line" "$(expr "$line" : '</*\([^ />]*\)')" ;;
            "<"*"/>")   [ -z "$handle_element_start" ]  || $handle_element_start    "$line" "$(expr "$line" : '</*\([^ />]*\)')"
                        [ -z "$handle_element_end" ]    || $handle_element_end      "$line" "$(expr "$line" : '</*\([^ />]*\)')" ;;
            "<"*)       [ -z "$handle_element_start" ]  || $handle_element_start    "$line" "$(expr "$line" : '</*\([^ />]*\)')" ;;
            *)          [ -z "$handle_characters" ]     || $handle_characters       "$line" ;;
        esac
    done
}

# splits an XML document into a stream of lines containing one element each and removes blanks
# TODO: make this more robust
bash_xml_split () {
    sed -e 's/</\
</g' -e 's/>/>\
/g' | sed -e '/^ *$/d'
}

if [ "$0" == "$BASH_SOURCE" ]; then
    bash_xml_split | bash_xml_sax_parse "$@"
fi
