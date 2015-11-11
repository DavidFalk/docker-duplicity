#!/bin/bash
day=$(date +"%m_%d_%Y")
starttime=$(date)

logger -t duplicity-runner "started"

encrypted=1

lines=$(cat /root/env.txt)
while read line
do
    first=$(echo $line | cut -d '=' -f 1)
    second=$(echo $line | cut -d '=' -f 2)
    if [ $first = "CLIENT" ]
    then
       client=$second
    fi
    if [ $first = "EMAIL" ]
    then
        email=$second
    fi
    if [ $first = "BACKUPSERVER" ]
    then
        backupserver=$second
    fi
    if [ $first = "PORT" ]
    then
        port=$second
    fi
    if [ $first = "ENCRYPT" ]
    then
        if [ $second = "NO" ]
        then
            encrypted=0
        fi
    fi
done <<< "$lines"

: ${client:?"Need to set client"}
: ${email:?"Need to set email"}
: ${backupserver:?"Need to set backupserver"}
: ${port:?"Need to set port"}

if [ $encrypted -eq 1 ]
then
    gpgkeys=$(gpg --list-keys)
    gpgkey=$(echo $gpgkeys | grep -o 'pub 2048R/.* [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' | grep -o '/.* ' | grep -o '[0-9A-Z]*')
    export PASSPHRASE=""
    logger -t duplicity-runner "gpgkey found $gpgkey"
    encrypttext="--encrypt-key $gpgkey"
else
    encrypttext="--no-encryption"
fi
echo "-----------------BACKUP STARTED $starttime-----------------" >> /logs/$day-duplicity.log

# doing a monthly full/incremental backup
logger -t duplicity-runner "doing a monthly full/incremental backup"
echo "-----------------MONTHLY FULL/INCREMENTAL BACKUP-----------------" >> /logs/$day-duplicity.log
/usr/local/bin/./duplicity --log-file /logs/$day-duplicity.log --allow-source-mismatch $encrypttext --full-if-older-than 1D /data sftp://$client@$backupserver:$port/backup
#echo "$backup_command" >> /logs/$day-duplicity.log
#expect /usr/bin/expect_ssh_fingerprint "$backup_command"

# cleaning the remote backup space (deleting backups older than 2 Months)
logger -t duplicity-runner "cleaning the remote backup space"
echo "-----------------CLEANING REMOTE BACKUP SPACE-----------------" >> /logs/$day-duplicity.log
/usr/local/bin/./duplicity --log-file /logs/$day-duplicity.log remove-all-but-n-full 2 --force sftp://$client@$backupserver:$port/backup
#echo "$cleaning_command" >> /logs/$day-duplicity.log
#expect_ssh_fingerprint $cleaning_command
endtime=$(date)

echo "-----------------BACKUP FINISHED $endtime-------------------" >> /logs/$day-duplicity.log
logger -t duplicity-runner "finished"

