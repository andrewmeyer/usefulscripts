#Written by Andrew Meyer for NGC
#Public Release Authorized

#! /bin/bash

LOGDIR=/home/gameservers/steamgames/killingfloor/System/logs
LOGBASE=kfserver
PIDDIR=/var/run/games
NUM=$1
MIN=0
WARN=$2
CRIT=$3
MAX=6

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

#this is what should happen
if [ $LOAD -le $MAX -a $LOAD -ge $MIN ]; then
	echo "OK: Server Running, last reported: $LOAD users | users=$LOAD;$WARN;$CRIT;$MIN;$MAX"
	exit 0
else
	echo "WARNING: PID Found,Garbled logs | users=$MIN;$WARN;$CRIT;$MIN;$MAX"
	exit 1
fi
