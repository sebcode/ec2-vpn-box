#!/bin/bash
set -e

if [ ! -f $PDIR/VPCID ]; then
    echo "VPC does not exist"
    exit 1
fi

VPCID=$(cat $PDIR/VPCID)

echo "VPC $VPCID: Enable DNS support"
aws ec2 modify-vpc-attribute --vpc-id $VPCID --enable-dns-support '{"Value":true}'
echo "VPC $VPCID: Enable DNS hostnames"
aws ec2 modify-vpc-attribute --vpc-id $VPCID --enable-dns-hostnames '{"Value":true}'
