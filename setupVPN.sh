#!/bin/bash
source $(dirname $0)/lib/script-init.sh

if [ ! -f $PDIR/PUBLICIP ]; then
    echo "Instance not started"
    exit 1
fi

PUBLICIP=$(cat $PDIR/PUBLICIP)
VPN_PASS=$(cat $PDIR/VPN_PASS)
VPN_PSK=$(cat $PDIR/VPN_PSK)

if ! which macosvpn > /dev/null; then
    echo "Install macosvpn first: brew install macosvpn"
    exit 1
fi

sudo macosvpn create --l2tp ec2vpnbox \
    --endpoint $PUBLICIP \
    --username vpnuser \
    --password $VPN_PASS \
    --shared-secret $VPN_PSK \
    --force

echo "VPN IP is $PUBLICIP"
echo "VPN password is $VPN_PASS"
echo "VPN PSK is $VPN_PSK"

