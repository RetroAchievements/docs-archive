#!/bin/bash
# md-toc.sh
############
# Generates a Table of Contents getting a markdown file as input.
#
# Inspiration for this script:
# https://medium.com/@acrodriguez/one-liner-to-generate-a-markdown-toc-f5292112fd14
#
# The list of invalid chars is probably incomplete, but is good enough for my
# current needs.
# Got the list from:
# https://github.com/thlorenz/anchor-markdown-header/blob/56f77a232ab1915106ad1746b99333bf83ee32a2/anchor-markdown-header.js#L25
#
# meleu - January/2019

INVALID_CHARS="'[]/?!:\`.,()*\";{}+=<>~$|#@&–—"

toc() {
    local line
    local level
    local title
    local anchor

    while IFS='' read -r line || [[ -n "$line" ]]; do
        level="$(echo "$line" | sed -E 's/^#(#+).*/\1/; s/#/    /g; s/^    //')"
        title="$(echo "$line" | sed -E 's/^#+ //')"
        anchor="$(echo "$title" | tr '[:upper:] ' '[:lower:]-' | tr -d "$INVALID_CHARS")"

        echo "$level- [$title](#$anchor)"
    done <<< "$(grep -E '^#{2,10} ' "$1" | tr -d '\r')"
}

main() {
    toc "$@"
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
