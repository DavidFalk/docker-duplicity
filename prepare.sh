#!/bin/bash

: ${CLIENT:?"Need to set CLIENT"}
: ${EMAIL:?"Need to set EMAIL"}
: ${BACKUPSERVER:?"Need to set BACKUPSERVER"}
: ${PORT:?"Need to set PORT"}

if [ ! -f /root/.ssh/id_rsa ]
then
    ssh-keygen -t rsa -q -f /root/.ssh/id_rsa -N ""
    echo "Created ssh key... needs to be moved to server"
fi

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
