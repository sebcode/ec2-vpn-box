#!/bin/bash
source $(dirname $0)/lib/script-init.sh

./lib/createKeypair.sh
./lib/createVpc.sh
./lib/setupVpc.sh
./lib/setupSecgroup.sh
./lib/createSubnet.sh
./lib/createInetgateway.sh
./lib/setupRoutetable.sh

echo Done.

