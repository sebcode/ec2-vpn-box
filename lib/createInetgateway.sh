#!/bin/bash
set -e

if [ ! -f $PDIR/VPCID ]; then
    echo "VPC does not exist, please create it first."
    exit 1
fi

VPCID="$(cat $PDIR/VPCID)"

if [ -f $PDIR/INETGATEWAYID ]; then
    INETGATEWAYID="$(cat $PDIR/INETGATEWAYID)"
    echo "Internet gateway already exists: $INETGATEWAYID"
else
    echo "Creating internet gateway"
    aws ec2 create-internet-gateway | tee $PDIR/create-internet-gateway ; test ${PIPESTATUS[0]} -eq 0
    INETGATEWAYID=$(cat $PDIR/create-internet-gateway | jq -r '.InternetGateway.InternetGatewayId')
    echo $INETGATEWAYID > $PDIR/INETGATEWAYID
    echo "Internet gateway created: $INETGATEWAYID"
fi

if [ "$(aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=$VPCID | jq -r '.InternetGateways[0].InternetGatewayId')" = "$INETGATEWAYID" ]; then
    echo "Internet gateway $INETGATEWAYID is already attached to VPC $VPCID"
else
    echo "Attaching internet gateway $INETGATEWAYID to VPC $VPCID"
    aws ec2 attach-internet-gateway --vpc-id $VPCID --internet-gateway-id $INETGATEWAYID ; test ${PIPESTATUS[0]} -eq 0
    echo "Internet internet gateway $INETGATEWAYID attached to VPC $VPCID"
fi

