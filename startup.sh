#!/bin/bash

set -e

source config.sh

OUTPUT_FILE=/tmp/output

test ! "$RUNNING_INSTANCE_ID" = "" && {
  echo "Box already seems to be running!" >&2
  echo "Instance ID $RUNNING_INSTANCE_ID" >&2
  exit 1;
}

echo "Starting box..."

TMPUSERDATA=$(mktemp)

cat > $TMPUSERDATA <<EOF
#!/bin/bash

PSK="$PSK"
VPN_USER="$VPN_USER"
VPN_PASSWORD="$VPN_PASSWORD"

NOIP_USER="$NOIP_USER"
NOIP_PASS="$NOIP_PASS"
NOIP_HOST="$NOIP_HOST"

EOF

cat ./lib/bootstrap.sh >> $TMPUSERDATA

$AWS ec2 run-instances \
  --region $REGION \
  --instance-type $INSTANCE_TYPE \
  --image-id $AMI \
  --subnet-id $SUBNET_ID \
  --key-name $KEY_NAME \
  --associate-public-ip-address \
  --user-data file://$TMPUSERDATA \
  > $OUTPUT_FILE

rm -f $TMPUSERDATA

INSTANCE_ID=$(cat $OUTPUT_FILE | jq -r ".Instances[0].InstanceId")

test "$INSTANCE_ID" = "" && {
  echo "Could not start our box :(" >&2
  exit 1;
}

echo -n $INSTANCE_ID > $STATE_FILE

echo "Box started. Instance ID is $INSTANCE_ID"
echo "Waiting to boot..."

while [ ! "$STATUS" = "running" ]; do
  STATUS=$($AWS ec2 describe-instances \
    --instance-id $INSTANCE_ID \
    --region $REGION \
    | jq -r ".Reservations[0].Instances[0].State.Name")

  echo "$(date) Status is $STATUS"

  sleep 1
done

echo "Done."

