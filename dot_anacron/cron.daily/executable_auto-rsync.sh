#!/bin/sh
CURRENT_DIR="$(dirname "$(which "$0")")"
pass show Remote/rsync | sshpass rsync -avzP --delete --delete-excluded --exclude-from="$CURRENT_DIR/rsync-homedir-excludes.txt" /home mahid@192.168.1.6::NetBackup
