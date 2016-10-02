#!/bin/bash
set -e

if [ ! -f $PDIR/VPCID ]; then
    echo "VPC does not exist, please create it first."
    exit 1
fi

VPCID="$(cat $PDIR/VPCID)"

if [ -f $PDIR/SUBNETID ]; then
    echo "Subnet already exists: $(cat $PDIR/SUBNETID)"
    exit 0
fi

B=$(((RANDOM % 127) + 1))
SUBNETCIDR="$(cat $PDIR/SUBNETCIDRPREFIX)$B.0/24"
echo $SUBNETCIDR > $PDIR/SUBNETCIDR

echo "Creating subnet for VPC $VPCID with CIDR block $SUBNETCIDR"
aws ec2 create-subnet --vpc-id $VPCID --cidr-block $SUBNETCIDR | tee $PDIR/create-subnet ; test ${PIPESTATUS[0]} -eq 0
SUBNETID=$(cat $PDIR/create-subnet | jq -r '.Subnet.SubnetId')
echo $SUBNETID > $PDIR/SUBNETID
echo "Subnet created for VPC $VPCID: $SUBNETID"

STATE=""
COUNTER=1
while [ ! "$STATE" = "available" ]; do
    echo "Waiting for Subnet to become available: $SUBNETID"
    aws ec2 describe-subnets --subnet-ids $SUBNETID | tee $PDIR/describe-subnets ; test ${PIPESTATUS[0]} -eq 0
    STATE=$(cat $PDIR/describe-subnets | jq -r ".Subnets[0].State")
    sleep 1

    COUNTER=$((COUNTER+1))
    if [ $COUNTER -gt 10 ]; then break; fi
done

echo "Subnet is available: $SUBNETID"

