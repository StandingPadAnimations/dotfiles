#!/bin/sh
sshpass -f ~/.secrets rsync --exclude-from=rsync-homedir-excludes.txt -aP --delete /home mahid@192.168.1.6::NetBackup
