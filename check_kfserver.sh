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
#echo $LOG
#echo $LOAD

#fix the random missing log errors
if [ -z "$LOAD" ]; then
#	echo "bad last entry, trying previous..."
	LOG=`cat $LOGDIR/$LOGBASE$NUM.log | grep "Sending updated" | tail -n 2 | head -n 1`
	LOAD=`echo "$LOG" | cut -d ' ' -f 15`
#	echo $LOG
#	echo $LOAD
#	echo "WARNING: bad log, last known: $LOAD users | users=$LOAD;$WARN;$CRIT;$MIN;$MAX"
#	exit 1
fi

#this is what should happen
if [ $LOAD -le $MAX -a $LOAD -ge $MIN ]; then
	echo "OK: Server Running, last reported: $LOAD users | users=$LOAD;$WARN;$CRIT;$MIN;$MAX"
	exit 0
else
	echo "WARNING: PID Found,Garbled logs | users=$MIN;$WARN;$CRIT;$MIN;$MAX"
	exit 1
fi

#Log: STEAMAUTH : Sending updated server details - NodNetwork Floor of killing [Chicago] OPEN 6 | 6
# echo "Log: STEAMAUTH : Sending updated server details - NodNetwork Floor of killing [Chicago] OPEN 1 | 6" | cut -d ' ' -f 15
#echo "WARNING: ${MEM_USEDM}MB | memory=${MEM_USEDM}MB;2000;2800;0;3072"
