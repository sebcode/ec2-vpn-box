#!/bin/bash
source $(dirname $0)/lib/script-init.sh

if [ ! -f $PDIR/PUBLICIP ]; then
    echo "Instance not started"
    exit 1
fi

PUBLICIP=$(cat $PDIR/PUBLICIP)

if [ ! -f $PDIR/prikey ]; then
    echo "Private key not found"
    exit 1
fi

ETCHOSTSIP="$(cat /etc/hosts | grep $LOCALHOSTNAME | awk '{ print $1 }')"

if [ "$ETCHOSTSIP" != "$PUBLICIP" ]; then
    echo "Update of /etc/hosts required."
    $(dirname $0)/updateetchosts.sh
fi

ssh -o ConnectTimeout=2 -i $PDIR/prikey "ubuntu@$LOCALHOSTNAME" $*

