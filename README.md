# ec2-vpn-box

Bash scripts to bootstrap a personal IPsec VPN connection via AWS EC2.

The scripts sets up all required AWS resources (Keypair, VPC, Security Group,
Subnet, Internet Gateway, Routes) for you and there is also a cleanup script
to delete all resources when you are done using it. The created AWS resources
do not interfere with your existing resources (as far as I know, so use at your
own risk).

The bootstrapped EC2 instance is a nano instance with Ubuntu 16.04 and
strongswan. UDP ports 4500 and 500 are open (for IPsec VPN) as well as
SSH port 22.

## Requirements

 * macOS (tested with Sierra, but probably works also with Yosemite/El Capitan)
 * `brew install aws jq macosvpn`
 * Amazon AWS account with root credentials

## Initial setup

Install the requirements and set up your AWS account:

 * Log in to AWS Console with your root or administrator user account.
 * Create a separate IAM user with `AmazonEC2FullAccess` policy
   (a bit more restricted policy works probably too).
 * Create a new AWS credentials profile for the IAM user you created previously:

        aws configure --profile ec2vpnbox

 * Edit `default.profile` file and change the region you want to connect to.

## Usage

 * Tell the scripts to load `default.profile`. You can create multiple profile
   files if you want to launch multiple EC2 instances.

        export PROFILE=default 

 * Bootstrap all required AWS resources.

        ./bootstrap.sh

 * Start a new EC2 instance. Note: After your instance state reached `running`,
   you may have to wait about 2-3 minutes for it to boot until it's accessible.
   Use `status.sh` continuously to check if the instance is ready to use.

        ./runInstance.sh

 * Show the status of the EC2 instance, instance uptime, instance IP and your current IP.

        ./status.sh

 * Goodie: ssh into the EC2 instance.

        ./ssh.sh

 * Setup macOS VPN configuration with `macosvpn`.

        ./setupVPN.sh
    
 * Connect to the vpn and watch netflix ...

 * Terminate the instance.

        ./terminateInstance.sh

 * Cleanup all previously created AWS resources associated with this profile.

        ./cleanup.sh

# Credits

Sebastian Volland - http://github.com/sebcode

