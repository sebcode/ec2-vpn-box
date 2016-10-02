#!/bin/bash
source $(dirname $0)/lib/script-init.sh

if [ ! -f $PDIR/INSTANCEID ]; then
    echo "Instance not started"
    exit 1
fi

INSTANCEID=$(cat $PDIR/INSTANCEID)

echo "Terminating instance $INSTANCEID"
aws ec2 terminate-instances --instance-ids $INSTANCEID | tee $PDIR/terminate-instance ; test ${PIPESTATUS[0]} -eq 0

STATE=""
COUNTER=1
while [ ! "$STATE" = "terminated" ]; do
    echo "Waiting for instance to terminate: $VPCID"
    aws ec2 describe-instances --instance-ids $INSTANCEID > $PDIR/describe-instance ; test ${PIPESTATUS[0]} -eq 0
    STATE=$(cat $PDIR/describe-instance | jq -r ".Reservations[0].Instances[0].State.Name")
    echo "State is $STATE"
    sleep 1

    COUNTER=$((COUNTER+1))
    if [ $COUNTER -gt 30 ]; then
        echo "Timeout"
        break
    fi
done

rm -f $PDIR/INSTANCEID
rm -f $PDIR/PUBLICIP
echo "Instance terminated: $INSTANCEID"

