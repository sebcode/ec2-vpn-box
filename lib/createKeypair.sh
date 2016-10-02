#!/bin/bash
set -e

if [ -f $PDIR/KEYPAIRNAME ]; then
    echo "Key pair already exists"
    KEYPAIRNAME=$(cat $PDIR/KEYPAIRNAME)
else
    KEYPAIRNAME="ec2vpnbox-$(((RANDOM % 900000)+100000))"
    aws ec2 create-key-pair --key-name $KEYPAIRNAME | tee $PDIR/create-key-pair ; test ${PIPESTATUS[0]} -eq 0
    echo $KEYPAIRNAME > $PDIR/KEYPAIRNAME
fi

cat $PDIR/create-key-pair |jq -r '.KeyMaterial' > $PDIR/prikey ; test ${PIPESTATUS[0]} -eq 0
chmod 600 $PDIR/prikey

