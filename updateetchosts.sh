#!/bin/bash
source $(dirname $0)/lib/script-init.sh

if [ ! -d ~/.ssh/config.d ]; then
    echo "Please mkdir ~/.ssh/config.d and add 'Include config.d/*' to ~/.ssh/config"
    exit 1
fi

if [ ! -f $PDIR/PUBLICIP ]; then
    echo "Instance not started"
    exit 1
fi

PUBLICIP=$(cat $PDIR/PUBLICIP)
ETCHOSTS=/etc/hosts
MATCHES="$(grep -n $LOCALHOSTNAME $ETCHOSTS | cut -f1 -d:)"
ENTRY="${PUBLICIP} ${LOCALHOSTNAME}"

if [ ! -z "$MATCHES" ]; then
    echo "Updating existing hosts entry."
    while read -r line_number; do
        sudo sed -i '' "${line_number}s/.*/${ENTRY} /" $ETCHOSTS
    done <<< "$MATCHES"
else
    echo "Adding new hosts entry."
    echo "$ENTRY" | sudo tee -a "$ETCHOSTS" > /dev/null
fi

ID_FILE=$(realpath $PDIR/prikey)

cat > ~/.ssh/config.d/ec2box <<EOF
Host $LOCALHOSTNAME
    Port 22
    User ubuntu
    IdentityFile $ID_FILE
    StrictHostKeyChecking no
    CheckHostIP no
    ControlMaster auto
    ControlPath ~/.ssh/%r@%h:%p.$PUBLICIP
    ControlPersist yes
EOF

