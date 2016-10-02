#!/bin/bash
source $(dirname $0)/lib/script-init.sh

if [ ! -f $PDIR/PUBLICIP ]; then
    echo "Instance not started"
    exit 1
fi

if [ ! -f $PDIR/INSTANCEID ]; then
    echo "Instance not started"
    exit 1
fi

PUBLICIP=$(cat $PDIR/PUBLICIP)
INSTANCEID=$(cat $PDIR/INSTANCEID)

aws ec2 describe-instances --instance-ids $INSTANCEID > $PDIR/describe-instance ; test ${PIPESTATUS[0]} -eq 0
STATE=$(cat $PDIR/describe-instance | jq -r ".Reservations[0].Instances[0].State.Name")
echo "Instance state is '$STATE'"

if [ "$STATE" = "running" ]; then
    ./ssh.sh uptime
fi

curl --silent http://freegeoip.net/json/ > $PDIR/geoinfo ; test ${PIPESTATUS[0]} -eq 0
cat $PDIR/geoinfo | jq .

CURRENTIP=$(cat $PDIR/geoinfo | jq -r '.ip')

if [ "$CURRENTIP" = "$PUBLICIP" ]; then
    echo "You are connected!"
else
    echo "You are not connected :("
fi

