#! /bin/bash
#control script for killingfloor, woot
#written by: Drew Meyer for NGC

#start:stop:restart:update:[stats]

GAMEDIR=/home/gameservers/steamgames/tf
STEAM=/home/gameservers/steamcmd/steam.sh
PROC=oink
GAME=/home/gameservers/steamcmd/tf.steam
ACTION=$1
SERVER=$2
MAX=1
NAME="Team Fortress 2"
PIDDIR=/var/run/games
PIDNAME=tfserver

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

game_update() {
	echo "beginning update process..."
	sleep 2

	$STEAM +runscript $GAME

	echo "Update process has completed"
}

game_start() {
	echo "Detecting if $NAME server $SERVER is already running..."
	ISRUNNING=`pidof $PROC`
	if [ ! -s $PIDDIR/$PIDNAME$SERVER.pid ]; then
	        echo "$NAME server $SERVER is not running."
	else
	        echo "PID file for $NAME server $SERVER already exists!"
	        echo "Having multiple instances of servers will create
		conflicts of epic proportions.  Terminate existing instance? (y/n/[Ctrl+C
		to abort]):"
	        read input
        	if [ "$input" == "y" ]; then
                	echo "Terminating instance(s)"
	                kill `cat $PIDDIR/$PIDNAME$SERVER.pid`
			rm $PIDDIR/$PIDNAME$SERVER.pid
        	else
                	echo "Not Terminating. I hope you have a segfault
			bunker!"
	        fi
	fi
	cd $GAMEDIR/System
	echo "Starting server $SERVER..."
#NATURALLY THIS STARTS KILLINGFLOOR NOT TF2, JUST DEAL WITH IT FOR NOW
	`screen -dmS kf$SERVER ./ucc-bin server KF-farm.rom?game=KFmod.KFGameType?VACSecured=true?MaxPlayers=6?log=logs/$PIDNAME$SERVER.log -nohomedir ini=KillingFloor$SERVER.ini`
	game_makePID > $PIDDIR/$PIDNAME$SERVER.pid
	sleep 15
	echo "startup procedure completed, check screen for issues."
	echo ""
}

game_stop() {
	echo "checking for running $NAME server..."
        sleep 1

        if [ ! -s $PIDDIR/$PIDNAME$SERVER.pid ]; then
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
			PID=`cat $PIDDIR/$PIDNAME$SERVER.pid`
                        kill $PID
                        rm $PIDDIR/$PIDNAME$SERVER.pid
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
	update)
                SERVER=1
                while [ $SERVER -le $MAX ]; do
                      game_stop
                      SERVER=$[$SERVER+1]
                done

		game_update
	;;
	*)
		echo "Usage: $NAME start|stop|restart|update [server number (blank for all)]"
		exit 1
	;;
esac
