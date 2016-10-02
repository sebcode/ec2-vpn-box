#!/bin/bash
set -e

if [ ! -f $PDIR/INETGATEWAYID ]; then
    echo "Internet gateway does not exist"
    exit 0
fi

INETGATEWAYID="$(cat $PDIR/INETGATEWAYID)"

if [ -f $PDIR/VPCID ]; then
    VPCID="$(cat $PDIR/VPCID)"
    echo "Check if internet gateway $INETGATEWAYID is attached to VPC $VPCID"
    if [ ! "$(aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=$VPCID | jq -r '.InternetGateways[0].InternetGatewayId|tostring')" = "null" ]; then
        echo "Detaching internet gateway $INETGATEWAYID from VPC $VPCID"
        aws ec2 detach-internet-gateway --vpc-id $VPCID --internet-gateway-id $INETGATEWAYID ; test ${PIPESTATUS[0]} -eq 0
        echo "Detached internet gateway $INETGATEWAYID from VPC $VPCID"
    else
        echo "Internet gateway $INETGATEWAYID is not attached to $VPCID"
    fi
fi

echo "Deleting Internet gateway: $INETGATEWAYID"
aws ec2 delete-internet-gateway --internet-gateway-id $INETGATEWAYID ; test ${PIPESTATUS[0]} -eq 0
rm $PDIR/INETGATEWAYID
echo "Internet gateway deleted: $INETGATEWAYID"

