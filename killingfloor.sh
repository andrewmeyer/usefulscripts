#! /bin/bash
#control script for killingfloor, woot
#written by: Drew Meyer for NGC

#start:stop:restart:update:status:sync:[stats]
#needs: check_kfserver for status command

GAMEDIR=/home/gameservers/steamgames/killingfloor
STEAM=/home/gameservers/steamcmd/steam.sh
PROC=ucc-bin-real
GAME=/home/gameservers/steamcmd/killingfloor.steam
ACTION=$1
SERVER=$2
MAX=3
NAME=killingfloor
PIDDIR=/var/run/games
STATUSCHECK=/usr/lib/nagios/plugins/check_kfserver
#for our KF check, these are used only as a formality to the graphing program
USERWARN=6
USERCRIT=6


if [ ! -x $STEAM ] ;then
        echo "FATAL: $STEAM does not exist or is not executable"
        exit 2
#else
#        echo "$STEAM located and is executable"
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

game_status() {
RETURN=`$STATUSCHECK $SERVER $USERWARN $USERCRIT`
echo "$NAME $SERVER: $RETURN"
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

game_update() {
	echo "beginning update process..."
	sleep 2

	$STEAM +runscript $GAME

	echo "Update process has completed"
	echo ""
}

game_sync() {
        echo "beginning map checks"
#        $GAMEDIR/System/compress.sh
cd /home/gameservers/steamgames/killingfloor/System/
COUNT=`ls ../Maps/ | grep "rom" | wc`
echo $COUNT
MAX=`echo $COUNT | cut -d ' ' -f 1`
echo $MAX

NOW=1
   while [ $NOW -le $MAX ]; do
   MAP=`ls ../Maps/ | grep "rom" | head -n $NOW | tail -n 1`
   echo $NOW of $MAX...$MAP
   THISMD5=`md5sum ../Maps/$MAP`
   ARCHIVEMD5=`cat /home/gameservers/.killingfloor/Maps/$MAP.md5`
   if [ "$THISMD5" != "$ARCHIVEMD5" ] ; then
           echo "md5 hash mismatch, recompressing"
           ./ucc-bin compress  ../Maps/$MAP
           md5sum ../Maps/$MAP > /home/gameservers/.killingfloor/Maps/$MAP.md5
        else
           echo "md5 is identical, skipping"
   fi
 NOW=$[$NOW+1]
done

echo "scanning and updating remote files..."
rsync -e 'ssh -i /home/gameservers/.ssh/ftpuser.key -l ftpuser' -v /home/gameservers/.killingfloor/Maps/*uz2 files.nodnetwork.org:/home/ftp/kfmaps/
echo ""
echo ""
echo "map compression and updating completed"

}

game_start() {
	echo "Detecting if $NAME server $SERVER is already running..."
	ISRUNNING=`pidof $PROC`
	if [ ! -s $PIDDIR/kfserver$SERVER.pid ]; then
	        echo "$NAME server $SERVER is not running."
	else
	        echo "PID file for $NAME server $SERVER already exists!"
	        echo "Having multiple instances of UT servers will create
		conflicts of epic proportions.  Terminate existing instance? (y/n/[Ctrl+C
		to abort]):"
	        read input
        	if [ "$input" == "y" ]; then
                	echo "Terminating instance(s)"
	                kill `cat $PIDDIR/kfserver$SERVER.pid`
			rm $PIDDIR/kfserver$SERVER.pid
        	else
                	echo "Not Terminating. I hope you have a segfault
			bunker!"
	        fi
	fi
	cd $GAMEDIR/System
	echo "Starting server $SERVER..."
	`screen -dmS kf$SERVER ./ucc-bin server KF-farm.rom?game=KFmod.KFGameType?VACSecured=true?MaxPlayers=6?log=logs/kfserver$SERVER.log -nohomedir ini=KillingFloor$SERVER.ini`
	sleep 1
	game_makePID > $PIDDIR/kfserver$SERVER.pid
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

        if [ ! -s $PIDDIR/kfserver$SERVER.pid ]; then
		echo "No PID found for $NAME server $SERVER,"
	else
		echo "PID found for $NAME server $SERVER, checking load"
		LOAD=`game_status | cut -d ' ' -f 8`
		echo $LOAD
		if [ $LOAD -eq 0 ]; then
			echo "$NAME server $SERVER appears empty,"
		else
			echo "WARNING:"
	                echo "$NAME server $SERVER already appears to be loaded"
        	        echo "shutting down will boot ALL players."
			echo ""
			 echo "Are you SURE you want to shut down now? y/N"
			read input
				if [ ! "$input" == "y" ]; then
					echo "Aborting, good call..."
					sleep 1
					exit 1
                		fi
		fi
                echo "Stopping $NAME server $SERVER..."
		PID=`cat $PIDDIR/kfserver$SERVER.pid`
                kill $PID
                rm $PIDDIR/kfserver$SERVER.pid
		sleep 2
		echo "Shutdown completed..."
		sleep 1
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
	update)
                SERVER=1
                while [ $SERVER -le $MAX ]; do
                      game_stop
                      SERVER=$[$SERVER+1]
                done

		game_update
		game_sync
	;;
	sync)
		game_sync
	;;

	status)
	if [ -n "$SERVER" ]; then
                        game_status
                else
                        SERVER=1
                        while [ $SERVER -le $MAX ]; do
                                game_status
                                SERVER=$[$SERVER+1]
                        done
                fi

	;;
	*)
		echo "Usage: $NAME start|stop|restart|update|sync|status [server number (blank for all)]"
		exit 1
	;;
esac
