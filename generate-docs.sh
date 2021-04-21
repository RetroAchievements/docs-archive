#!/bin/bash
# generate-docs.sh
##################


# globals #####################################################################

readonly SCRIPT_DIR="$(cd "$(dirname $0)" && pwd)"

function exit_error() {                                                                                     
    echo -e "ERROR: $@" >&2                                                                                 
    exit 1                                                                                                  
}       

generate_nav_section() {
    local tmp
    local mdfile
    local sidebar="$SCRIPT_DIR/docs.wiki/_Sidebar.md"
    [[ -f "$sidebar" ]] || return 1

    cd "$(dirname "$sidebar")"

    echo "nav:"

    while IFS='' read -r line || [[ -n "$line" ]]; do
        case "$line" in
            "## [About](About)")
                echo "  - About:"
                echo "    - About.md"
                ;;

            "## "*)
                echo "  - ${line/### /}:"
                [[ "$line" == *"General"* ]] && echo "    - index.md"
                ;;

            "### "*)
                echo "    - ${line/#### /}:"
                ;;

            *"- "*)
                if [[ "$line" == *"- ["* ]]; then
                    # example of input/output of the sed below:
                    # in : - [Tips and Tricks](Tips-and-Tricks)
                    # out: - Tips and Tricks: Tips-and-Tricks.md
                    tmp="$(sed 's/\[\(.*\)\](\(.*\))/\1: \2/' <<< "$line").md"
                    echo "    $tmp"

                    mdfile="$(echo "${tmp// /}" | cut -d: -f2)"
                    echo -e "\n\n\n## Changelog\n\nLast 10 changes on this page:\n" >> "$mdfile"
                    git log -n 10 --date=format:"%Y-%m-%d %H:%M" --pretty=format:"- \`[%cd] %cn:\` %s" "$mdfile" >> "$mdfile"
                else
                    echo "    $line:"
                fi
                ;;
        esac

    done < "$sidebar"
    cd - > /dev/null
}


function main() {
    cd "$SCRIPT_DIR"

    echo "--- Getting wiki pages..."
    git clone https://github.com/RetroAchievements/docs.wiki.git

    cd docs.wiki || exit_error "There's something wrong with 'docs.wiki' directory."

    ln -sf Home.md index.md
    echo -e "\n\n\n## Changelog\n\nLast 10 changes on this page:\n" >> Home.md
    git log -n 10 --date=format:"%Y-%m-%d %H:%M" --pretty=format:"- \`[%cd] %cn:\` %s" Home.md >> Home.md

    echo "--- Done!"
    echo

    echo "--- Configure CNAME..."
    echo 'docs.retroachievements.org' > CNAME
    echo "--- Done!"
    echo

    cd - >/dev/null
    cp -R img docs.wiki/

    echo "--- Generating the custom mkdocs.yml..."
    cp template.mkdocs.yml mkdocs.yml || exit_error "Failed to copy \"mkdocs.yml\"."
    generate_nav_section >> mkdocs.yml || exit_error "Failed to generate \"nav:\" section."
    echo "--- Done!"
    echo

    docker container run --rm -v ${PWD}:/docs squidfunk/mkdocs-material gh-deploy --force
}


main "$@"
