#!/bin/bash
set -e

if [ ! -f $PDIR/VPCID ]; then
    echo "VPC does not exist"
    exit 0
fi

VPCID="$(cat $PDIR/VPCID)"

echo "Check VPC state: $VPCID"
aws ec2 describe-vpcs --vpc-id $VPCID | tee $PDIR/describe-vpc ; test ${PIPESTATUS[0]} -eq 0
STATE=$(cat $PDIR/describe-vpc | jq -r ".Vpcs[0].State")

if [ ! "$STATE" = "available" ]; then
    echo "VPC status must be 'available', actual: $STATE"
    exit 1
fi

echo "Deleting VPC: $VPCID"

aws ec2 delete-vpc --vpc-id $VPCID | tee $PDIR/delete-vpc ; test ${PIPESTATUS[0]} -eq 0
rm $PDIR/VPCID

echo "VPC deleted: $VPCID"

