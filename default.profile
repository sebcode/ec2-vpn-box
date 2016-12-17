
# This is the name of the awscli profile you configured with `aws configure`
export AWS_DEFAULT_PROFILE="ec2vpnbox"

# Choose your region
# 
# us-east-1 - US East (N. Virginia)
# us-east-2 - US East (Ohio)
# us-west-2 - US West (Oregon)
# us-west-1 - US West (N. California)
# ca-central-1 - Canada (Central)
# eu-west-1 - EU (Ireland)
# eu-west-2 - EU (London)
# eu-central-1 - EU (Frankfurt)
# ap-southeast-1 - Asia Pacific (Singapore)
# ap-northeast-1 - Asia Pacific (Tokyo)
# ap-southeast-2 - Asia Pacific (Sydney)
# ap-northeast-2 - Asia Pacific (Seoul)
# ap-south-1 - Asia Pacific (Mumbai)
# sa-east-1 - South America (São Paulo)
#
export AWS_DEFAULT_REGION="us-east-1"

# Type of the EC2 instance. The nano instance is the smallest and cheapest one,
# and should probably be good enough for a personal VPN.
export INSTANCETYPE="t2.nano"

