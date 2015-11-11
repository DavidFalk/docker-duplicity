#!/bin/bash

: ${CLIENT:?"Need to set CLIENT"}
: ${EMAIL:?"Need to set EMAIL"}
: ${BACKUPSERVER:?"Need to set BACKUPSERVER"}
: ${SERVERKEY:?"Need to set SERVERKEY"}
: ${PORT:?"Need to set PORT"}

if [ -f /cron/crons.conf ]
then
    rm /root/crons.conf
    cp /cron/crons.conf /root/crons.conf
else
    cp /root/crons.conf /cron/crons.conf
fi

crontab /root/crons.conf

if [ ! -f /root/.ssh/id_rsa ]
then
    ssh-keygen -t rsa -q -f /root/.ssh/id_rsa -N ""
    echo "Created ssh key... needs to be moved to server"
fi

printf "[${BACKUPSERVER}]:$PORT ${SERVERKEY}\n\r">/root/.ssh/known_hosts

if [[ ! $ENCRYPT == "NO" ]]
then
    if [ ! -f /root/.gnupg/pubring.gpg ]
    then
        #Generate GPG keys
        echo "Generate GPG keys"

        cat >gpgconfig <<EOF
              Key-Type: 1
              Key-Length: 2048
              Name-Real: $CLIENT
              Name-Email: $EMAIL
              Expire-Date: 0
EOF
    gpg --batch --gen-key gpgconfig
    fi
fi
env > /root/env.txt
