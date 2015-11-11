#!/bin/bash

day=$(date +"%m_%d_%Y")
starttime=$(date)

logger -t duplicity-restore "started"

env > /root/env.txt
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
done <<< "$lines"

: ${client:?"Need to set client"}
: ${email:?"Need to set email"}
: ${backupserver:?"Need to set backupserver"}
: ${port:?"Need to set port"}

logger -t duplicity-restore "attempting restore"

/usr/local/bin/./duplicity restore -t $1 sftp://$client@$backupserver:$port/backup $2/data

logger -t duplicity-restore "finished"
