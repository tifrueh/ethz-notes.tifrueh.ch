#!/bin/zsh

ETHZ_NOTES_TIFRUEH_PUBLIC="${ETHZ_NOTES_TIFRUEH}/public/"

printt () {
    title="=== ${1} "
    echo "${(r:80::=:)title}"
}

printt "BEGIN GIT PULL"

cd "${ETHZ_NOTES_TIFRUEH}"

for gd in $(find . -name '.git' -type d); do
    gitdir="$(realpath $gd/..)"
    GIT_CMD="git -C '${gitdir}' pull"
    printf '%s\n' "$GIT_CMD"
    read 'CONT?Continue? [y/N] '
    [[ "$CONT" = 'y' || "$CONT" = 'Y' ]] || continue
    eval "$GIT_CMD"
done

printt "END GIT PULL"

printt "BEGIN HUGO"
hugo --source "${ETHZ_NOTES_TIFRUEH}" --destination "${ETHZ_NOTES_TIFRUEH_PUBLIC}"
printt "END HUGO"

printt "BEGIN RSYNC"
RSYNC_CMD="sudo rsync --del -vrlpt '${ETHZ_NOTES_TIFRUEH_PUBLIC}' '${ETHZ_NOTES_TIFRUEH_SRV}'"
printf '%s\n' "$RSYNC_CMD"
read 'CONT?Continue? [y/N] '
[[ "$CONT" = 'y' || "$CONT" = 'Y' ]] || exit 0
eval "$RSYNC_CMD"
printt "END RSYNC"
