#!/bin/sh

if [ ! -e /proc/meminfo ]; then
	echo "FATAL: Cannot open /proc/meminfo"
	exit 3
fi

MEM_TOTAL=`awk '/MemTotal/ { print $2 }' /proc/meminfo`
MEM_FREE=`awk '/MemFree/ { print $2 }' /proc/meminfo`
MEM_CACHED=`awk '/Cached/ { print $2 }' /proc/meminfo | head -1`

WARN=8192
CRIT=10240

#echo "T= $MEM_TOTAL"
#echo "F1= $MEM_FREE"
#echo "C= $MEM_CACHED"
#Cache Adjust
MEM_FREE=`expr $MEM_FREE + $MEM_CACHED`

#echo "F2= $MEM_FREE"

MEM_USED=`expr $MEM_TOTAL - $MEM_FREE`
MEM_USEDM=`expr $MEM_USED / 1024`
#MEMINFO=$(</proc/meminfo)

#calculate total MB
MEM_TOTALM=`expr $MEM_TOTAL / 1024`

#echo "U1= $MEM_USED"
#echo "U2= $MEM_USEDM"
if [ $MEM_USEDM -ge $CRIT ]; then
	echo "CRITICAL: ${MEM_USEDM}MB | memory=${MEM_USEDM}MB;$WARN;$CRIT;0;$MEM_TOTALM"
	exit 2
elif [ $MEM_USEDM -ge $WARN ]; then
	echo "WARNING: ${MEM_USEDM}MB | memory=${MEM_USEDM}MB;$WARN;$CRIT;0;$MEM_TOTALM"
	exit 1
else
	echo "OK: ${MEM_USEDM}MB | memory=${MEM_USEDM}MB;$WARN;$CRIT;0;$MEM_TOTALM"
	exit 0
fi
#MemTotal:       524288 kB
#MemFree:        311064 kB
exit 4
