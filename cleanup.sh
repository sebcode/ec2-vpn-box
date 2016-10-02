#!/bin/bash
source $(dirname $0)/lib/script-init.sh

./lib/deleteKeypair.sh
./lib/deleteInetgateway.sh
./lib/deleteSubnet.sh
./lib/deleteVpc.sh

echo Done.

