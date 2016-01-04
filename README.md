
# ec2-vpn-box

Here are some helper scripts for an EC2-based on-demand ipsec VPN instance.

The `start.sh` script will launch an EC2 nano instance with Ubuntu and a ready to use VPN.

If you don't need the instance any more, use `terminate.sh` to terminate it.

The EC2 instance will be set up with ipsec VPN and update a no-ip.org hostname.

This script has been tested with Bash 4.3.42 on Mac OS X 10.11. Should work
for other configurations too.

## Initial setup

 * Set up your AWS account:

      * Log in to AWS Console with your root or administrator user account.
      * Create a separate IAM user with `AmazonEC2FullAccess` policy
        (a bit more restricted policy works probably too).
      * Create an access key for this user and save it somewhere.
      * Make sure your have a Public Subnet and a Internet Gateway in your VPC
        configuration. See
        [VPC Secenario 1 in Amazon VPC documentation](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenario1.html)
        for more information. If you have an older AWS account you probably
        need to create them manually.
      * In EC2 Dashboard, go to "Key Pairs" and create a key pair named `ec2vpnbox`.
        With this key pair you can access your instance with SSH.
        Creating a key pair will trigger the download of a PEM file.

 * Copy the key pair file somewhere and change the permissions.

        mkdir -p ~/.ec2/
        mv ~/Downloads/ec2vpnbox.pem ~/.ec2/
        chmod 600 ~/.ec2/ec2vpnbox.pem

 * Install dependencies. You need the AWS Commandline tools and jq for the scripts to work.
   jq is a really cool JSON parser that the scripts use to parse awscli's JSON output.
   If you use Mac OS X and homebrew do this:

        brew install awscli jq

 * Create a new AWS credentials profile for the IAM user you created previously:

        aws configure --profile ec2vpnbox

 * Edit configuration.

      * First, find out your subnet ID. If you only have one VPC subnet, use this to find it out:

            aws --profile seb ec2 describe-subnets --region eu-west-1 | jq -r '.Subnets[0].SubnetId'

      * Copy the sample configuration file and edit it with your favorite text editor.

            cp config.sample.sh config.sh
            vim config.sh

      * You probably want to edit at least:

        * `SUBNET_ID`
        * `REGION`
        * `PSK`, `VPN_USER`, `VPN_PASSWORD`
        * `NOIP_USER`, `NOIP_PASS`, `NOIP_HOST`

 * Start your VPN box:

        ./start.sh

 * Show status:

        ./status.sh

 * Terminate your VPN box:

        ./terminate.sh

### VPN Client configuration on Mac OS X

 * Go to "System Preferences" -> "Network"

 * Add a new network interface

   * Interface: VPN
   * VPN Type: L2TP over IPSec
   * Service name: ec2vpnbox

 * Set "Server Address" to your dynamic DNS Hostname.

 * Go to "Authentication Settings..."

   * Set "User Authentication" -> "Password" to your VPN password
   * Set "Machine Authentication" -> "Shared Secret" to your shared secret (`PSK`)

 * Click "Connect"

