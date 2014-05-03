#!/bin/sh
###Version 2.1
EGREP=/bin/egrep
IFCONFIG=/sbin/ifconfig
iface=$1
if [ ! -x "$EGREP" ]; then
        echo "FATAL: $EGREP cannot be found or is not executable!"
        exit 5
fi
if [ ! -x "$IFCONFIG" ]; then
        echo "FATAL: $IFCONFIG cannot be found or is not executable!"
        exit 5
fi

${IFCONFIG} ${iface} | ${EGREP} -o 'inet addr:[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?' | cut -d: -f2

