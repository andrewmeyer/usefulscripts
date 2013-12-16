#!/bin/sh

#
# Check_memory.sh
# Provides a way for Nagios to closely estimate the current memory usage of a server.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.




if [ ! -e /proc/meminfo ]; then
	echo "FATAL: Cannot open /proc/meminfo | memory=0;0;0;0;0"
	exit 3
fi

MEM_TOTAL=`awk '/MemTotal/ { print $2 }' /proc/meminfo`
MEM_FREE=`awk '/MemFree/ { print $2 }' /proc/meminfo`
MEM_CACHED=`awk '/Cached/ { print $2 }' /proc/meminfo | head -1`

#give default WARNL and CRITL
if [ -n "$1" ]; then
	WARNL=0.6
else
	WARNL= `expr $1 / 100`
fi

if [ -n "$1" ]; then
	CRITL=0.8
else
	CRITL= `expr $2 / 100`
fi


#Cache Adjust
MEM_FREE=`expr $MEM_FREE + $MEM_CACHED`

MEM_USED=`expr $MEM_TOTAL - $MEM_FREE`
MEM_USEDM=`expr $MEM_USED / 1024`

#calculate total MB
MEM_TOTALM=`expr $MEM_TOTAL / 1024`

#calculate WARN
WARN=1
WARN= `expr $MEM_TOTALM * WARNL`

#calculate CRIT
CRIT=1
CRIT= `expr $MEM_TOTAL * CRITL`


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
exit 4
