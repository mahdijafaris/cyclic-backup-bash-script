#!/bin/bash

# This script should be run as the administrator user (e.g., in the crontab of root).

# This is a script to backup some directories from a remote server via SSH access. The list of directories is given in the 'SRC_DIR_LIST' array.


## Configuration
DST_HOST="root@srv_IP" #Username and IP address of the remote server
SRV_NAME="srv_name" #The directory name assigned for this particular server in the local machine.
LOCAL_USR="mahdi"
LOCAL_GRP="mahdi"
BACKUP_DIR="/mnt/Backup" # Backup directory on the local machine.
SRC_DIR_LIST=("/etc" "/root" "/var/opt/backups")

BACKUP_DAILY=true # if set to false backup will not work
BACKUP_WEEKLY=true # if set to false backup will not work
BACKUP_MONTHLY=true # if set to false backup will not work
BACKUP_RETENTION_DAILY=15
BACKUP_RETENTION_WEEKLY=10
BACKUP_RETENTION_MONTHLY=24

LOCAL_USR_GRP="$LOCAL_USR:$LOCAL_GRP"


MONTH=`date +%d`
DAYWEEK=`date +%u`

if [[ ( $MONTH -eq 1 ) && ( $BACKUP_MONTHLY == true ) ]];
        then
        FN=monthly
elif [[ ( $DAYWEEK -eq 7 ) && ( $BACKUP_WEEKLY == true ) ]];
        then
        FN=weekly
elif [[ ( $DAYWEEK -lt 7 ) && ( $BACKUP_DAILY == true ) ]];
        then
        FN=daily
fi

DateTime=`date +%Y-%m-%d_%H-%M-%S`
SrvBkpDir=$BACKUP_DIR/$SRV_NAME
ThisBkpDir=$SrvBkpDir/Bkp.$FN.$DateTime
LnkDstDir=$SrvBkpDir/Bkp.last

echo "------------------------------"
echo "Start backing up $SRV_NAME ..."
echo "Data and Time: $DateTime"


for SrcDir in "${SRC_DIR_LIST[@]}"; do
    echo "------------------------------"
    echo "Start backup directory $SrcDir from $SRV_NAME ..."
    echo " "
    sudo -u $LOCAL_USR mkdir -p $ThisBkpDir$SrcDir
    rsync -ahvz -e 'ssh' --progress --delete --chown=$LOCAL_USR_GRP --compress-level=9 --link-dest="$LnkDstDir$SrcDir"\
        $DST_HOST:$SrcDir/ $ThisBkpDir$SrcDir 
    echo " "
    echo "Done with the backup of $SrcDir"
    echo "------------------------------"
done

rm -f $LnkDstDir
sudo -u $LOCAL_USR ln -s $ThisBkpDir $SrvBkpDir/Bkp.last

cd $SrvBkpDir
ls -t | grep daily | sed -e 1,"$BACKUP_RETENTION_DAILY"d | xargs -d '\n' rm -R > /dev/null 2>&1
ls -t | grep weekly | sed -e 1,"$BACKUP_RETENTION_WEEKLY"d | xargs -d '\n' rm -R > /dev/null 2>&1
ls -t | grep monthly | sed -e 1,"$BACKUP_RETENTION_MONTHLY"d | xargs -d '\n' rm -R > /dev/null 2>&1

