#!/bin/zsh

# External Variables:
#
# ETHZ_NOTES_TIFRUEH_HUGO       Path to the hugo root.
# ETHZ_NOTES_TIFRUEH_WWW        Path to the webserver root.
# ETHZ_NOTES_TIFRUEH_USR        The user with which to rsync.
# ETHZ_NOTES_TIFRUEH_HEADLESS   Set to some value to run non-interactively.

hugo="$ETHZ_NOTES_TIFRUEH_HUGO"
hugo_public="${ETHZ_NOTES_TIFRUEH_HUGO}/public/"
www="$ETHZ_NOTES_TIFRUEH_WWW"
headless="$ETHZ_NOTES_TIFRUEH_HEADLESS"

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

printt "BEGIN GIT PULL"

cd "$hugo"

for gd in $(find . -name '.git' -type d); do
    gitdir="$(realpath $gd/..)"
    git_cmd="git -C '${gitdir}' pull"
    confirm_eval "$git_cmd"
done

printt "END GIT PULL"

printt "BEGIN HUGO"
hugo --source "${hugo}" --destination "${hugo_public}"
printt "END HUGO"

printt "BEGIN RSYNC"
rsync_cmd="${rsync_prefix}rsync --del -vrlpt '${hugo_public}' '${www}'"
confirm_eval "$rsync_cmd"
printt "END RSYNC"
