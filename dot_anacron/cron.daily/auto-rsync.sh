#!/bin/sh
sshpass -f ~/.secrets rsync -avzP --delete --delete-excluded --exclude-from=rsync-homedir-excludes.txt /home mahid@192.168.1.6::NetBackup
