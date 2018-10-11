#!/bin/bash
# generate-docs.sh
##################


# globals #####################################################################

DEPS=(git python3 python3-pip libyaml-dev)
DEP_FILES=(git python3 pip3 /usr/include/yaml.h)
PIP_PKGS=(mkdocs mkdocs-material)

readonly SCRIPT_DIR="$(cd "$(dirname $0)" && pwd)"

SERVE_FLAG=0
DEPLOY_FLAG=0


# functions ###################################################################

function exit_error() {
    echo -e "ERROR: $@" >&2
    exit 1
}


function print_help() {
    local ret="$1"
    echo "$(basename "$0") [OPTIONS]"
    echo
    echo "Where OPTIONS are:"
    echo
    # getting the help message from the comments in this source code
    sed -n 's/^#H //p' "$0"
# FIXME    exit "$ret"
}


function check_deps() {
    local pkg
    local not_installed=()

    for pkg in "${DEP_FILES[@]}"; do
        if ! which "$pkg" 2>&1 >/dev/null; then
            if [[ "$pkg" == *"yaml.h" ]]; then
                [[ -f "$pkg" ]] && continue
            fi

            not_installed+=("$pkg")
            echo "WARNING: $pkg not found!" >&2
        fi
    done

    # if deps are installed, check for mkdocs stuff
    if [[ -n "$not_installed" ]]; then
        exit_error "missing dependencies!\n" \
            "To use this tool you must install the following packages:\n" \
            "${DEPS[@]}\n" >&2
    fi

    # TODO: check for mkdocs and mkdocs-material
}


function get_pages_section() {
    local tmp
    local sidebar="$SCRIPT_DIR/docs.wiki/_Sidebar.md"
    [[ -f "$sidebar" ]] || return 1

    echo "pages:"

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
                    echo "    $(sed 's/\[\(.*\)\](\(.*\))/\1: \2/' <<< "$line").md"
                else
                    echo "    $line:"
                fi
                ;;
        esac

    done < "$sidebar"
}


function parse_args() {
    if [[ -z "$@" ]]; then
        print_help
        exit
        # FIXME: exit must be on print_help() and do not exit if sourced script
    fi

    while [[ -n "$1" ]]; do
        case "$1" in

#H -h|--help        Print this help message and exit.
#H 
            -h|--help)
                print_help
                exit
                # FIXME: exit must be on print_help() and do not exit if sourced script
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
    check_deps

    parse_args "$@"

    cd "$SCRIPT_DIR"

    echo "--- Getting wiki pages..."
    git submodule update --recursive --remote || exit_error "Failed to get wiki pages."
    echo "--- Done!"
    echo

    cp -R img docs.wiki/
#    cp -R css docs.wiki/

    cd docs.wiki
    ln -sf Home.md index.md

    # ugly hack to config the custom domain docs.retroachievements.org
    echo 'docs.retroachievements.org' > CNAME
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
        mkdocs gh-deploy -f temp-mkdocs.yml -m "generated <http://docs.retroachievements.org> pages - $(date +'%Y-%m-%d %H:%M:%S')" || exit_error "Failed to generate/deploy pages to GitHub."
        echo "--- Done!"
        echo
    fi
}


main "$@"
