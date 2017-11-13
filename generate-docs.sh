#!/bin/bash
# generate-docs.sh
##################
# TODO: add an --install option to install mkdocs, material theme, etc...


# globals #####################################################################

readonly SCRIPT_DIR="$(cd "$(dirname $0)" && pwd)"

SERVE_FLAG=0
DEPLOY_FLAG=0


# functions ###################################################################

function exit_error() {
    echo "ERROR: $@" >&2
    exit 1
}


function get_pages_section() {
    local sidebar="$SCRIPT_DIR/docs.wiki/_Sidebar.md"
    [[ -f "$sidebar" ]] || return 1

    echo "pages:"
    echo "    - index.md"

    while IFS='' read -r line || [[ -n "$line" ]]; do
        case "$line" in
            "## User docs")
                echo "    - User docs:" ;;

            "## Developer docs")
                echo "    - Developer docs:" ;;

            "- "*)
                echo "        $(sed 's/\[.*\](\(.*\))/\1/' <<< "$line").md" ;;
        esac

    done < "$sidebar"
}


function parse_args() {
    while [[ -n "$1" ]]; do
        case "$1" in

#H -h|--help        Print this help message and exit.
#H 
            -h|--help)
                echo "$(basename "$0") [OPTIONS]"
                echo
                echo "Where OPTIONS are:"
                echo
                # getting the help message from the comments in this source code
                sed -n 's/^#H //p' "$0"
                exit
                ;;

#H -s|--serve       Serve the docs locally after generating the pages.
#H 
            -s|--serve)
                SERVE_FLAG=1
                ;;

#H -d|--deploy      Deploy the docs to GitHub pages after generating the pages.
#H 
            -d|--deploy)
                DEPLOY_FLAG=1
                ;;
            *)  break
                ;;
        esac
        shift
    done
}


function main() {
    parse_args "$@"

    cd "$SCRIPT_DIR"

    echo "--- Getting wiki pages..."
    git submodule update --recursive --remote || exit_error "Failed to get wiki pages."
    echo "--- Done!"
    echo

    cp -R img docs.wiki/

    cd docs.wiki
    ln -sf Home.md index.md
    cd -

    echo "--- Generating the custom mkdocs.yml..."
    cp mkdocs.yml temp-mkdocs.yml || exit_error "Failed to copy \"mkdocs.yml\"."
    get_pages_section >> temp-mkdocs.yml || exit_error "Failed to generate \"pages:\" section."
    echo "--- Done!"
    echo

    if [[ "$SERVE_FLAG" == "1" ]]; then
        echo "--- Generating and serving the pages locally..."
        echo "--- (hit CTRL+C to terminate)"
        mkdocs serve -f temp-mkdocs.yml || exit_error "Failed to generate/serve pages locally."
        echo "--- Done!"
        echo
    fi

    if [[ "$DEPLOY_FLAG" == "1" ]]; then
        echo "--- Generating and deploying the pages to GitHub..."
        mkdocs gh-deploy -f temp-mkdocs.yml || exit_error "Failed to generate/deploy pages to GitHub."
        echo "--- Done!"
        echo
    fi
}

main "$@"
