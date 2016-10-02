#!/bin/bash
set -e

if [ ! -f $PDIR/VPCID ]; then
    echo "VPC does not exist"
    exit 1
fi

VPCID=$(cat $PDIR/VPCID)

if [ ! -f $PDIR/INETGATEWAYID ]; then
    echo "Internet gateway does not exist"
    exit 1
fi

INETGATEWAYID=$(cat $PDIR/INETGATEWAYID)

if [ ! -f $PDIR/SUBNETID ]; then
    echo "Subnet does not exist"
    exit 1
fi

SUBNETID=$(cat $PDIR/SUBNETID)

echo "Fetch route table ID for VPC $VPCID"
aws ec2 describe-route-tables --filter Name=vpc-id,Values=$VPCID > $PDIR/describe-route-tables ; test ${PIPESTATUS[0]} -eq 0
RTID=$(cat $PDIR/describe-route-tables | jq -r '.RouteTables[0].RouteTableId')
echo $RTID > $PDIR/RTID
echo "Route table ID is $RTID"

echo "Creating route for route table $RTID and internet gateway $INETGATEWAYID"
aws ec2 create-route --route-table-id $RTID --destination-cidr-block 0.0.0.0/0 --gateway-id $INETGATEWAYID

echo "Associate route table $RTID to Subnet $SUBNETID"
aws ec2 associate-route-table --route-table-id $RTID --subnet-id $SUBNETID

