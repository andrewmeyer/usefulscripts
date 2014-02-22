#! /bin/bash

# Check_kfserver.sh
# provides a way for Nagios to pull the status and user load of a given KillingFloor server.
#
# Copyright (c) 2014 Andrew Meyer <ameyer+secure@nodnetwork.org>
#
#
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.




LOGDIR=/home/gameservers/steamgames/killingfloor/System/logs
LOGBASE=kfserver
PIDDIR=/var/run/games
NUM=$1
MIN=0
WARN=$2
CRIT=$3
MAX=6
PID=`cat $PIDDIR/$LOGBASE$NUM.pid`

#see if game is even running
if [ ! -s $PIDDIR/$LOGBASE$NUM.pid ]; then
	echo "UNKNOWN: no PID found | users=$MIN;$WARN;$CRIT;$MIN;$MAX"
	exit 4
fi

#do we have log files?
if [ ! -s $LOGDIR/$LOGBASE$NUM.log ]; then
	echo "WARNING: PID Found, Log file missing | users=$MIN;$WARN;$CRIT;$MIN;$MAX"
	exit 1
fi

LOG=`cat $LOGDIR/$LOGBASE$NUM.log | grep "Sending updated" | tail -n 1`
LOAD=`echo "$LOG" | cut -d ' ' -f 15`

#fix the random missing log errors
if [ -z "$LOAD" ]; then
	LOG=`cat $LOGDIR/$LOGBASE$NUM.log | grep "Sending updated" | tail -n 2 | head -n 1`
	LOAD=`echo "$LOG" | cut -d ' ' -f 15`
fi

#predictive failure check
PIDINFO=`ps -e | grep "$PID"`
if [ -z "$PIDINFO" ]; then
	echo "CRITICAL: Predictive Failure Detected | users=$MIN;$WARN;$CRIT;$MIN;$MAX"
	exit 3
fi

#this is what should happen
if [ $LOAD -le $MAX -a $LOAD -ge $MIN ]; then
	echo "OK: Server Running, last reported: $LOAD users | users=$LOAD;$WARN;$CRIT;$MIN;$MAX"
	exit 0
else
	echo "WARNING: PID Found,Garbled logs | users=$MIN;$WARN;$CRIT;$MIN;$MAX"
	exit 1
fi
