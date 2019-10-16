#!/bin/bash

SELF="${BASH_SOURCE[0]##*/}"
NAME="${SELF%.sh}"

OPTS="i:r:d:svxEh"
USAGE="Usage: $SELF [$OPTS]"

HELP="
$USAGE

    Options:
        -i      Inotify Watcher arg (Implemented: create,delete,move,modify)
        -r      Remote Host with destination dir
        -d      Source dir
        -s      simulate
        -v      set -v
        -x      set -x
        -E      set -vE
        -h      Help

    Example:
        Sync only Create and modify:
            $SELF -i create,modify -S ~/syncDir example.com:/backup/
"

_quit (){
    local retCode="$1" msg="${@:2}"

    printf '%s\n' "$msg"
    exit $retCode
}

inotifyWatcher="modify,create,delete,move"

_rsyncRunner(){
    local src="$1" host="$2" rsyncOpts+=" $3"

    $_run rsync -av $rsyncOpts "$src" "${host%/}/${src#/}"
}

while getopts "${OPTS}" arg; do
    case "${arg}" in
        i) inotifyWatcher="$OPTARG"                                     ;;
        r) host="$OPTARG"                                               ;;
        d) sourceDir="$OPTARG"                                          ;; 
        s) _run="echo"                                                  ;;
        v) set -v                                                       ;;
        x) set -x                                                       ;;
        E) set -vE                                                      ;;
        h) _quit 0 "$HELP"                                              ;;
        ?) _quit 1 "Invalid Argument: $USAGE"                           ;;
        *) _quit 1 "$USAGE"                                             ;;
    esac
done
shift $((OPTIND - 1))

# Check if all binary's exist
for bin in "inotifywait" "rsync"; do
    type "$bin" &>/dev/null || _quit 2 "$bin: not found in $PATH"
done

# TODO: Implement Config File and multiple server as destination
# check if config file exist and is readable
#if [[ -f "$configFile" ]]; then
#    _quit 2 "Configuration file is not readable!"
#fi
#
# source configuration file
#source $configFile

while read srcDir action file; do
    case "${action,,}" in
        *modify*|*create*)      _rsyncRunner "${srcDir%/}/$file" "$host"                ;;
        *delete*|*move*)        _rsyncRunner "${srcDir%/}/$file" "$host" "--delete"     ;;
    esac
done < <(inotifywait -m -r -e "$inotifyWatcher" ${sourceDir})
