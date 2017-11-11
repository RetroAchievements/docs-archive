#!/bin/bash
# generate-docs.sh
##################
# TODO:
# - add an option to serve the pages locally (mkdocs serve).
# - add an option to deploy pages (mkdocs gh-deploy)

readonly SCRIPT_DIR="$(cd "$(dirname $0)" && pwd)"

function exit_error() {
    echo "ERROR: $@" >&2
    exit 1
}

function get_pages_section() {
    local sidebar="$SCRIPT_DIR/docs.wiki/_Sidebar.md"
    [[ -f "$sidebar" ]] || return 1

    echo "pages:"
    echo "    - index.md"

    while read -r line; do
        case "$line" in
            "## User docs")
                echo "    - User docs:" ;;

            "## Development docs")
                echo "    - Developer docs:" ;;

            "- "*)
                echo "        $(sed 's/\[.*\](\(.*\))/\1/' <<< "$line").md" ;;
        esac

    done < "$sidebar"
}

function main() {
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

    echo "--- Generating and deploying the pages to GitHub..."
    mkdocs gh-deploy -f temp-mkdocs.yml || exit_error "Failed to generate/deploy pages to GitHub."
    echo "--- Done!"
    echo
}

main
