#!/bin/bash

set -e

source config.sh

OUTPUT_FILE=/tmp/output

test "$RUNNING_INSTANCE_ID" = "" && {
  echo "Box is not running." >&2
  exit 1;
}

$AWS ec2 describe-instances \
  --instance-id $RUNNING_INSTANCE_ID \
  --region $REGION \
  > $OUTPUT_FILE

STATE=$(cat $OUTPUT_FILE | jq -r ".Reservations[0].Instances[0].State.Name")
PUBLIC_IP=$(cat $OUTPUT_FILE | jq -r ".Reservations[0].Instances[0].PublicIpAddress")

echo "State: $STATE"
echo "ssh -i $KEY_FILE ubuntu@$PUBLIC_IP"

