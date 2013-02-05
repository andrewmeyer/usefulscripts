# !/bin/bash

#this program simplifies the update command for steam's HLDS tool
#Programmed by Drew Meyer for NodNetwork 2011
#V 2.0

#param checks
if [ -z "$1" ]; then
        echo "INVALID SYNTAX: systax should be : update <game name>"
        exit
fi
GAME=$1

#the default dir should be the name of the game, if not, it may be specified but will generate a warning.
if [ -z "$2" -o "$1" = "$2" ]; then
	LOC=$GAME
	echo "***"
	echo "Using default game dir ($LOC)"
	echo "***"
else
		echo "***"
	        echo "NON DEFAULT GAME DIR SPECIFIED, proceeding with $2 as game dir"
		echo "***"
		LOC=$2
		sleep 1
fi

STEAM=/home/gameservers/steam
cd /home/gameservers/

#check is the steam process is where we think it is
if [ ! -x "$STEAM" ]; then
	echo "FATAL: $STEAM cannot be found!"
	exit 2
fi

#check if LOC exists
if [ ! -e "$LOC" ]; then
        echo "INVALID GAME DIR OR DIR DOES NOT EXIST, do you wish to create $LOC? [Y/n]"
	read input

	if [ "$input" == "Y" ]; then
		mkdir $LOC
	else
		echo "exiting..."
		sleep 1
		exit 1
	fi
fi

"$STEAM" -command update -game "$GAME" -dir "$LOC"
