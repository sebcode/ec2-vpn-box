#!/bin/bash
source $(dirname $0)/lib/script-init.sh

if [ -f $PDIR/INSTANCEID ]; then
    echo "Instance already started"
    exit 1
fi

if [ ! -f $PDIR/VPCID ]; then
    echo "VPC does not exist"
    exit 1
fi

VPCID=$(cat $PDIR/VPCID)

if [ ! -f $PDIR/SUBNETID ]; then
    echo "Subnet does not exist"
    exit 1
fi

SUBNETID=$(cat $PDIR/SUBNETID)

if [ ! -f $PDIR/KEYPAIRNAME ]; then
    echo "Key pair does not exist"
    exit 1
fi

KEYPAIRNAME=$(cat $PDIR/KEYPAIRNAME)

if [ ! -f $PDIR/SECGROUPID ]; then
    echo "Security group does not exist"
    exit 1
fi

SECGROUPID=$(cat $PDIR/SECGROUPID)

AMI=$(cat lib/amis | grep ^$AWS_DEFAULT_REGION | cut -d= -f2)

if [ "$AMI" = "" ]; then
    echo "Cannot get AMI for region $AWS_DEFAULT_REGION"
    exit 1
fi

echo "Starting instance with type $INSTANCETYPE in region $AWS_DEFAULT_REGION with AMI $AMI"

# Ask for password to update /etc/hosts right at the beginning.
echo "May ask for sudo password to allow modification of /etc/hosts."
sudo ls > /dev/null

START_TIME=$(date)

VPN_PASS=$(pwgen -n 10 1)
VPN_PSK=$(pwgen -n 10 1)

echo $VPN_PASS > $PDIR/VPN_PASS
echo $VPN_PSK > $PDIR/VPN_PSK

BOOTFILE=$PDIR/server-bootstrap
echo "#!/bin/bash" > $BOOTFILE
echo "VPN_USER=vpnuser" >> $BOOTFILE
echo "VPN_PASS=$VPN_PASS" >> $BOOTFILE
echo "VPN_PSK=$VPN_PSK" >> $BOOTFILE
cat lib/server-bootstrap >> $BOOTFILE

EXTRA=$(dirname $0)/server-bootstrap-extra
if [ -f "$EXTRA" ]; then
    cat $EXTRA >> $BOOTFILE
fi

echo 'echo -n 1 > /tmp/.boot_done' >> $BOOTFILE

echo $VPN_PASS > $PDIR/VPN_PASS
echo $VPN_PSK > $PDIR/VPN_PSK

aws ec2 run-instances \
    --instance-type $INSTANCETYPE \
    --image-id $AMI \
    --subnet-id $SUBNETID \
    --key-name $KEYPAIRNAME \
    --security-group-ids $SECGROUPID \
    --associate-public-ip-address \
    --user-data file://$BOOTFILE \
    | tee $PDIR/run-instance ; test ${PIPESTATUS[0]} -eq 0

INSTANCEID=$(cat $PDIR/run-instance | jq -r '.Instances[0].InstanceId')
echo $INSTANCEID > $PDIR/INSTANCEID
echo "Instance started: $INSTANCEID"

STATE=""
COUNTER=1
while [ ! "$STATE" = "running" ]; do
    echo "Waiting for instance to become available: $VPCID"
    aws ec2 describe-instances --instance-ids $INSTANCEID > $PDIR/describe-instance ; test ${PIPESTATUS[0]} -eq 0
    STATE=$(cat $PDIR/describe-instance | jq -r ".Reservations[0].Instances[0].State.Name")
    echo "State is $STATE"
    sleep 1

    COUNTER=$((COUNTER+1))
    if [ $COUNTER -gt 30 ]; then
        echo "Timeout"
        exit 1
    fi
done

PUBLICIP=$(cat $PDIR/describe-instance | jq -r ".Reservations[0].Instances[0].PublicIpAddress")
echo -n $PUBLICIP > $PDIR/PUBLICIP

echo "Instance is available: $INSTANCEID"
echo "Public IP: $PUBLICIP"

echo Update /etc/hosts
$(dirname $0)/updateetchosts.sh

COUNTER=1
while true; do
    echo "Waiting for SSH port to be reachable"
    set +e
    nc -G 2 -zv $PUBLICIP 22
    if [ "$?" = "0" ]; then
        break
    fi
    sleep 1
    set -e

    COUNTER=$((COUNTER+1))
    if [ $COUNTER -gt 60 ]; then
        echo "Timeout"
        exit 1
    fi
done

# Remove possible old key entry from SSH known hosts file.
ssh-keygen -R $LOCALHOSTNAME

COUNTER=1
while true; do
    echo "Waiting for instance to boot"

    SSH=$(dirname $0)/ssh.sh
    if [ "$($SSH cat /tmp/.boot_done)" = "1" ]; then
        break;
    fi
    sleep 1

    COUNTER=$((COUNTER+1))
    if [ $COUNTER -gt 60 ]; then
        echo "Timeout"
        exit 1
    fi
done

echo "Start: $START_TIME"
echo "Now:   $(date)"
echo Done.

