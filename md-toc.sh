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
# The list of valid markdown extensions was obtained here:
# https://superuser.com/a/285878
#
# meleu - January/2019

INVALID_CHARS="'[]/?!:\`.,()*\";{}+=<>~$|#@&–—"
VALID_EXTENSIONS='markdown|mdown|mkdn|md|mkd|mdwn|mdtxt|mdtext|text|Rmd|txt'

USAGE="\nUsage:\n$0 markdownFile.md"

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

validate_file() {
    local mdfile="$1"
    if [[ -z "$mdfile" ]]; then
        echo "ERROR: missing input markdown file." >&2
        return 1
    elif [[ ! -f "$mdfile" ]]; then
        echo "ERROR: \"$mdfile\": no such file." >&2
        return 1
    elif [[ ! "${mdfile##*.}" =~ ^($EXTENSIONS)$ ]]; then
        echo "ERROR: \"$mdfile\": invalid file extension (is it a markdown formatted file?)." >&2
        echo "Valid extensions: "$(echo "$VALID_EXTENSIONS" | tr '|' ' ')"" >&2
        return 1
    fi
}


main() {
    local mdfile="$1"

    validate_file "$mdfile" && toc "$mdfile" || echo -e "$USAGE"
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
