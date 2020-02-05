# Cyclic Backup Bash Script

This is a script to backup some directories from a remote server via SSH access. The list of directories is given in the 'SRC_DIR_LIST' array.

The backup is done in an incremental way using 'rsync' which creates hard links between different versions of backup.

This script is written based on: https://github.com/todiadiyatmo/bash-backup-rotation-script
