#!/bin/zsh

# External Variables:
#
# WWW_ETHZ_NOTES_TIFRUEH_USER   Remote user to use.
# WWW_ETHZ_NOTES_TIFRUEH_HOST   Remote host to use.
# WWW_ETHZ_NOTES_TIFRUEH_PATH   Remote path to use.

# Run in script directory.
cd "${0:A:h}"

# Setup helper variables.
ruser="${WWW_ETHZ_NOTES_TIFRUEH_USER:-user}"
rhost="${WWW_ETHZ_NOTES_TIFRUEH_HOST:-host}"
rpath="${WWW_ETHZ_NOTES_TIFRUEH_PATH:-path}"
hugo_static="./static/"
hugo_public="./public/"
hugo_info_txt="${hugo_static}/info.txt"
info_template="info.txt
========

Hugo Information
----------------
Hugo version: %s
Build started at: %s

Version Information
-------------------
"

# Define helper functions.
printt () {
    title="=== ${1} "
    echo "${(r:80::=:)title}"
}

confirm_eval () {
    printf '%s\n' "$1"
    read 'CONT?Continue? [y/N] '
    [[ "$CONT" = 'y' || "$CONT" = 'Y' ]] || return 1
    eval "$1"
}

# Setup info.txt.
mkdir -p "$hugo_static"
echo '*' > "${hugo_static}/.gitignore"
printf "$info_template" "$(hugo version)" "$(date -Iseconds)" > "$hugo_info_txt"

printt "BEGIN GIT PULL"

for gd in $(find . -name '.git' -type d); do
    git_dir="$(realpath $gd/..)"
    git_cmd="git -C '${git_dir}' pull"
    confirm_eval "$git_cmd"
    printf 'Repository %s: %s\n' "$(basename $git_dir)" "$(git -C $git_dir rev-parse HEAD)" >> "$hugo_info_txt"
done

printt "END GIT PULL"

printt "BEGIN HUGO"
confirm_eval "rm -rf '${hugo_public}'"
hugo --environment "production" --minify --destination "${hugo_public}"
printt "END HUGO"

printt "BEGIN RSYNC"
rsync_cmd="rsync --del -vrlpt '${hugo_public}' '${ruser}@${rhost}:${rpath}'"
confirm_eval "$rsync_cmd"
printt "END RSYNC"
