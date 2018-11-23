#!/bin/bash
#
# Copyright (c) 2013-2014 Wind River Systems, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#

# Inventory "goenabled" check.
# Wait for inventory information to be posted prior to allowing goenabled.

NAME=$(basename $0)
INVENTORY_READY_FLAG=/var/run/.inventory_ready

logfile=/var/log/platform.log

function LOG()
{
    logger "$NAME: $*"
    echo "`date "+%FT%T"`: $NAME: $*" >> $logfile
}

count=0
while [ $count -le 45 ]
do
    if [ -f $INVENTORY_READY_FLAG ]
    then
        echo "Inventory goenabled iterations PASS $count"
        LOG "Inventory goenabled iterations PASS $count"
        exit 0
    fi
    sleep 1
    (( count++ ))
done

echo "Inventory goenabled iterations FAIL $count"

LOG "Inventory is not ready. Continue."
exit 0
