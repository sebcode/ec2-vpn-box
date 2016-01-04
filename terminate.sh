#!/bin/bash

set -e

source config.sh

test "$RUNNING_INSTANCE_ID" = "" && {
  echo "Box does not seem to be running!" >&2
  exit 1;
}

echo "Instance ID: $RUNNING_INSTANCE_ID"

$AWS ec2 terminate-instances \
  --instance-ids $RUNNING_INSTANCE_ID \
  --region $REGION

echo "" > $STATE_FILE

echo "Done."

