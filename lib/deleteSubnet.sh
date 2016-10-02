#!/bin/bash
set -e

if [ ! -f "$PDIR/SUBNETID" ]; then
    echo "Subnet does not exist yet"
    exit 0
fi

SUBNETID="$(cat $PDIR/SUBNETID)"

echo "Deleting Subnet: $SUBNETID"

aws ec2 delete-subnet --subnet-id $SUBNETID | tee $PDIR/delete-subnet ; test ${PIPESTATUS[0]} -eq 0
rm $PDIR/SUBNETID

echo "Subnet deleted: $SUBNETID"

