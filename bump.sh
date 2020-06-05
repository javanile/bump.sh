#!/usr/bin/env bash

set -e

##
# Define which files to update and the pattern to look for
#
# $1 Current version
# $2 New version
##
bump_files () {
    [[ -f "${2}/package.json" ]] && bump_package_json "$1" "${2}"
	#bump README.md "my-plugin v$current_version" "my-plugin v$new_version"
}

##
#
##
bump_package_json () {
	from_version=$(grep -Po '(?<="version": ")[^"]*' "${2}/package.json")
	next_version=$(bump_version "$1" "${from_version}")

	echo "${from_version} --> ${next_version}"
	file_update \
	    "${2}/package.json" \
	    "\"version\": \"${from_version}\"" \
	    "\"version\": \"${next_version}\""
}

##
#
##
file_update () {
	tmp_file=$(mktemp)
	rm -f "${tmp_file}"
	sed -i "s/$2/$3/1w ${tmp_file}" $1
	rm -f "${tmp_file}"
}

##
#
##
bump_version () {
    from_version=${2:-0.0.0}

    IFS='.' read -a parts <<< "${from_version}"

    major=${parts[0]}
    minor=${parts[1]}
    patch=${parts[2]}

    case "$1" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            echo "Fail."
            exit 1
            ;;
    esac

    next_version="${major}.${minor}.${patch}"

    if [[ "${next_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo ${next_version}
    else
        echo ${from_version}
    fi
}

main () {
    if [ "$1" == "" ]; then
        echo >&2 "No 'from' version set. Aborting."
        exit 1
    fi


    confirm "Bump version number from $current_version to $new_version?"

    bump_files "$current_version" "$new_version"


    new_tag="v$new_version"
}

##
#
##
main () {
    if [[ -z "$1" ]]; then
        echo >&2 "No 'from' version set. Aborting."
        exit 1
    fi

    cwd=${2:-./}

    bump_files $1 ${cwd}
}


