#! /bin/bash
#control script for Terraria
#written by: Drew Meyer for NGC

#start:stop:restart:update:[stats]

GAMEDIR=/home/gameservers/terraria
PROC=ucc-bin-real
GAME=/home/gameservers/terraria/Terraria_Server.exe
ACTION=$1
SERVER=$2
MAX=1
NAME=Terraria
PIDDIR=/var/run/games


if [ ! -x $GAME ] ;then
        echo "FATAL: $GAME does not exist or is not executable"
        exit 2
#else
#        echo "$GAME located and is executable"
fi

if [ ! -r $STEAM ] ;then
        echo "FATAL: Cannot find config at $GAME"
        exit 2
#else
#        echo "$GAME located"
fi
if [ ! -d $GAMEDIR ]; then
	echo "FATAL: $GAMEDIR does not exist or is not a directory"
	exit 2
fi

game_makePID() {
INFO=`ps -A | grep "$PROC" | tail -n 1`
PID=`echo $INFO | cut -d ' ' -f 1`
echo $PID
}

function showBar {
 percDone=$(echo 'scale=2;'$1/$2*100 | bc)
 barLen=$(echo ${percDone%'.00'})
 bar=''
 fills=''
 for (( b=0; b<$barLen; b++ ))
 do
  bar=$bar"="
 done
 blankSpaces=$(echo $((100-$barLen)))
 for (( f=0; f<$blankSpaces; f++ ))
 do
  fills=$fills"_"
 done
 echo -ne '['$bar'>'$fills'] - '$barLen'%\r'
}

#game_update() {
#	echo "beginning update process..."
#	sleep 2
#
#	$STEAM +runscript $GAME
#
#	echo "Update process has completed"
#	echo ""
#}

#game_sync() {
#        echo "beginning map checks"
##        $GAMEDIR/System/compress.sh
#cd /home/gameservers/steamgames/killingfloor/System/
#COUNT=`ls ../Maps/ | grep "rom" | wc`
#echo $COUNT
#MAX=`echo $COUNT | cut -d ' ' -f 1`
#echo $MAX

#NOW=1
#   while [ $NOW -le $MAX ]; do
#   MAP=`ls ../Maps/ | grep "rom" | head -n $NOW | tail -n 1`
#   echo $NOW of $MAX...$MAP
#   THISMD5=`md5sum ../Maps/$MAP`
#   ARCHIVEMD5=`cat /home/gameservers/.killingfloor/Maps/$MAP.md5`
#   if [ "$THISMD5" != "$ARCHIVEMD5" ] ; then
#           echo "md5 hash mismatch, recompressing"
#           ./ucc-bin compress  ../Maps/$MAP
#           md5sum ../Maps/$MAP > /home/gameservers/.killingfloor/Maps/$MAP.md5
#        else
#           echo "md5 is identical, skipping"
#   fi
# NOW=$[$NOW+1]
#done
#
#echo "scanning and updating remote files..."
#rsync -v /home/gameservers/.killingfloor/Maps/*uz2 ftpuser@files.nodnetwork.org:/home/ftp/kfmaps/
#echo ""
#echo ""
#echo "map compression and updating completed"
#
#}

game_start() {
	echo "Detecting if $NAME server $SERVER is already running..."
	ISRUNNING=`pidof $PROC`
	if [ ! -s $PIDDIR/terraria$SERVER.pid ]; then
	        echo "$NAME server $SERVER is not running."
	else
	        echo "PID file for $NAME server $SERVER already exists!"
	        echo "Having multiple instances of UT servers will create
		conflicts of epic proportions.  Terminate existing instance? (y/n/[Ctrl+C
		to abort]):"
	        read input
        	if [ "$input" == "y" ]; then
                	echo "Terminating instance(s)"
	                kill `cat $PIDDIR/terraria$SERVER.pid`
			rm $PIDDIR/terraria$SERVER.pid
        	else
                	echo "Not Terminating. I hope you have a segfault
			bunker!"
	        fi
	fi
	cd $GAMEDIR/System
	echo "Starting server $SERVER..."
	`screen -dmS kf$SERVER ./$GAME`
	sleep 1
	game_makePID > $PIDDIR/terraria$SERVER.pid
	for (( i=0; i<=25; i++ ))
	do
		 showBar $i 25
		 sleep .5
	done
	echo ""
	echo "startup procedure completed, check screen for issues."
	echo ""
}

game_stop() {
	echo "checking for running $NAME server..."
        sleep 1

        if [ ! -s $PIDDIR/terraria$SERVER.pid ]; then
		echo "No PID found for $NAME server $SERVER,"
	else
		echo "WARNING:"
                echo "$NAME server $SERVER already appears to be running,"
                echo "shutting down will boot ALL players."
                echo ""
                echo "Are you SURE you want to shut down now? y/N"
                read input
                if [ ! "$input" == "y" ]; then
                        echo "Aborting, good call..."
                        sleep 1
                        exit 1
                else
                        echo "Stopping $NAME server $SERVER..."
			PID=`cat $PIDDIR/terraria$SERVER.pid`
                        kill $PID
                        rm $PIDDIR/terraria$SERVER.pid
			sleep 2
			echo "Shutdown completed..."
			sleep 1
                fi
	fi
	echo ""
}

case $ACTION in
	start)
		if [ -n "$SERVER" ]; then
			game_start
		else
			SERVER=1
			while [ $SERVER -le $MAX ]; do
				game_start
				SERVER=$[$SERVER+1]
			done
		fi
	;;
	stop)
                if [ -n "$SERVER" ]; then
                        game_stop
                else
                        SERVER=1
                        while [ $SERVER -le $MAX ]; do
                                game_stop
                                SERVER=$[$SERVER+1]
                        done
                fi
	;;
	restart)
                if [ -n "$SERVER" ]; then
                        game_stop
			game_start
                else
                        SERVER=1
                        while [ $SERVER -le $MAX ]; do
                                game_stop
				game_start
                                SERVER=$[$SERVER+1]
                        done
                fi
	;;
#	update)
#                SERVER=1
#                while [ $SERVER -le $MAX ]; do
#                      game_stop
#                      SERVER=$[$SERVER+1]
#                done
#
#		game_update
#		game_sync
#	;;
#	sync)
#		game_sync
#	;;
	*)
		echo "Usage: $NAME start|stop|restart [server number (blank for all)]"
		exit 1
	;;
esac
