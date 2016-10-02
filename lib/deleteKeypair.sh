#!/bin/bash
set -e

if [ ! -f "$PDIR/KEYPAIRNAME" ]; then
    echo "Key pair not created yet"
    exit 0
fi

KEYPAIRNAME=$(cat $PDIR/KEYPAIRNAME)

echo "Deleting key pair $KEYPAIRNAME"
aws ec2 delete-key-pair --key-name $KEYPAIRNAME ; test ${PIPESTATUS[0]} -eq 0
rm $PDIR/KEYPAIRNAME
rm -f $PDIR/prikey
echo "Key pair deleted: $KEYPAIRNAME"

