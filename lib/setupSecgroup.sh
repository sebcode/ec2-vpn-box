#!/bin/bash
set -e

if [ ! -f $PDIR/VPCID ]; then
    echo "VPC does not exist, please create it first."
    exit 1
fi

VPCID="$(cat $PDIR/VPCID)"

echo "Query security group for VPC $VPCID"
aws ec2 describe-security-groups --filter Name=vpc-id,Values=$VPCID > $PDIR/describe-security-group ; test ${PIPESTATUS[0]} -eq 0

SECGROUPID=$(cat $PDIR/describe-security-group | jq -r '.SecurityGroups[0].GroupId')
echo $SECGROUPID > $PDIR/SECGROUPID
echo "Security group for VPC $VPCID is: $SECGROUPID"

if [ ! "$INGRESS_TCP_PORTS" = "" ]; then do
    for PORT in "$INGRESS_TCP_PORTS"; do
        HASRULE=$(cat $PDIR/describe-security-group \
            | jq '.SecurityGroups[0].IpPermissions[] | (.FromPort|tostring) + "," + (.ToPort|tostring) + "," + (.IpProtocol|tostring) + "," + (.IpRanges[0].CidrIp)' \
            | jq -r "select(. | contains(\"$PORT,$PORT,tcp,0.0.0.0/0\")) != \"\"")

        if [ "$HASRULE" = "true" ]; then
            echo "Ingress rule for TCP port $PORT already exists"
        else
            echo "Create ingress rule for TCP port $PORT"
            aws ec2 authorize-security-group-ingress --group-id $SECGROUPID --protocol tcp --port $PORT --cidr 0.0.0.0/0 ; test ${PIPESTATUS[0]} -eq 0
        fi
    done
fi

if [ ! "$INGRESS_UDP_PORTS" = "" ]; then do
    for PORT in "$INGRESS_UDP_PORTS"; do
        HASRULE=$(cat $PDIR/describe-security-group \
            | jq '.SecurityGroups[0].IpPermissions[] | (.FromPort|tostring) + "," + (.ToPort|tostring) + "," + (.IpProtocol|tostring) + "," + (.IpRanges[0].CidrIp)' \
            | jq -r "select(. | contains(\"$PORT,$PORT,udp,0.0.0.0/0\")) != \"\"")

        if [ "$HASRULE" = "true" ]; then
            echo "Ingress rule for UDP port $PORT already exists"
        else
            echo "Create ingress rule for UDP port $PORT"
            aws ec2 authorize-security-group-ingress --group-id $SECGROUPID --protocol udp --port $PORT --cidr 0.0.0.0/0 ; test ${PIPESTATUS[0]} -eq 0
        fi
    done
fi

