
Usage: bsync.sh [i:r:d:svxEh]

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
            bsync.sh -i create,modify -S ~/syncDir example.com:/backup/

