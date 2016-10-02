#!/bin/bash
set -e

if [ -f $PDIR/VPCID ]; then
    echo "VPC already exists: $(cat $PDIR/VPCID)"
    exit 0
fi

B=$(((RANDOM % 127) + 1))
SUBNETCIDRPREFIX="10.$B."
echo $SUBNETCIDRPREFIX > $PDIR/SUBNETCIDRPREFIX
VPCCIDR="${SUBNETCIDRPREFIX}0.0/16"
echo $VPCCIDR > $PDIR/VPCCIDR

echo "Creating VPC with CIDR block $VPCCIDR"
aws ec2 create-vpc --cidr-block $VPCCIDR | tee $PDIR/create-vpc ; test ${PIPESTATUS[0]} -eq 0
VPCID=$(cat $PDIR/create-vpc | jq -r .Vpc.VpcId)
echo $VPCID > $PDIR/VPCID
echo "Created VPC: $VPCID"

STATE=""
COUNTER=1
while [ ! "$STATE" = "available" ]; do
    echo "Waiting for VPC to become available: $VPCID"
    aws ec2 describe-vpcs --vpc-id $VPCID | tee $PDIR/describe-vpc ; test ${PIPESTATUS[0]} -eq 0
    STATE=$(cat $PDIR/describe-vpc | jq -r ".Vpcs[0].State")
    sleep 1

    COUNTER=$((COUNTER+1))
    if [ $COUNTER -gt 10 ]; then
        echo "Timeout"
        break
    fi
done

echo "VPC is available: $VPCID"

