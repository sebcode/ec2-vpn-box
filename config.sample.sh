
# awscli profile name (see `aws configure list`)
PROFILE=ec2vpnbox

INSTANCE_TYPE=t2.nano

# Ubuntu Server 14.04 LTS (HVM), SSD Volume Type - ami-47a23a30
AMI=ami-47a23a30

REGION=eu-west-1

# VPN credentials
PSK="secret"
VPN_USER="username"
VPN_PASSWORD="password"

# no-ip.org credentials to update hostname
NOIP_USER=""
NOIP_PASS=""
NOIP_HOST=""

# VPC Subnet ID. Find it out with:
# aws --profile ec2vpnbox ec2 describe-subnets --region eu-west-1 | jq -r '.Subnets[0].SubnetId'
SUBNET_ID=subnet-xxxxxxxx

KEY_NAME=ec2vpnbox
KEY_FILE="~/.ec2/ec2vpnbox.pem"
STATE_FILE="~/.ec2-vpn-box"

# Expand ~ for paths
KEY_FILE="${KEY_FILE/#\~/$HOME}"

STATE_FILE="${STATE_FILE/#\~/$HOME}"

RUNNING_INSTANCE_ID=$(test -f $STATE_FILE && cat $STATE_FILE || true)

AWS="aws --profile $PROFILE"

