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

ssh -p 22 -i $PDIR/prikey "ubuntu@$PUBLICIP" $*

