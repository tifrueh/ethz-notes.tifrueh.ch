#!/bin/zsh

# External Variables:
#
# ETHZ_NOTES_TIFRUEH_HUGO       Path to the hugo root.
# ETHZ_NOTES_TIFRUEH_WWW        Path to the webserver root.
# ETHZ_NOTES_TIFRUEH_USR        The user with which to rsync.
# ETHZ_NOTES_TIFRUEH_HEADLESS   Set to some value to run non-interactively.

hugo="$ETHZ_NOTES_TIFRUEH_HUGO"
hugo_public="${ETHZ_NOTES_TIFRUEH_HUGO}/public/"
hugo_content="${ETHZ_NOTES_TIFRUEH_HUGO}/content/"
hugo_static="${ETHZ_NOTES_TIFRUEH_HUGO}/static/"
hugo_info_txt="${hugo_static}/info.txt"
www="$ETHZ_NOTES_TIFRUEH_WWW"
headless="$ETHZ_NOTES_TIFRUEH_HEADLESS"

info_template="info.txt
========

Hugo Information
----------------
Hugo version: %s
Build started at: %s

Version Information
-------------------
"

if [ -n "$ETHZ_NOTES_TIFRUEH_USR" ]; then
    rsync_prefix="sudo -u ${ETHZ_NOTES_TIFRUEH_USR} "
else
    rsync_prefix=""
fi

printt () {
    title="=== ${1} "
    echo "${(r:80::=:)title}"
}

confirm_eval () {
    if [[ -z "$headless" ]]; then
        printf '%s\n' "$1"
        read 'CONT?Continue? [y/N] '
        [[ "$CONT" = 'y' || "$CONT" = 'Y' ]] || return 1
    fi
    eval "$1"
}

echo '*' > "$hugo_static/.gitignore"
printf "$info_template" "$(hugo version)" "$(date -Iseconds)" > "$hugo_info_txt"

cd "$hugo"

printt "BEGIN GIT PULL"

for gd in $(find . -name '.git' -type d); do
    git_dir="$(realpath $gd/..)"
    git_cmd="git -C '${git_dir}' pull"
    confirm_eval "$git_cmd"
    printf 'Repository %s: %s\n' "$(basename $git_dir)" "$(git -C $git_dir rev-parse HEAD)" >> "$hugo_info_txt"
done

printt "END GIT PULL"

printt "BEGIN HUGO"
hugo --source "${hugo}" --destination "${hugo_public}"
printt "END HUGO"

printt "BEGIN RSYNC"
rsync_cmd="${rsync_prefix}rsync --del -vrlpt '${hugo_public}' '${www}'"
confirm_eval "$rsync_cmd"
printt "END RSYNC"
