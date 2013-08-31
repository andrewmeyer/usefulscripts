# !/bin/bash

#
# update.sh
# Provides a tool to use Steam's (outdated but still used) HLDS tool.
#
# Copyright (c) 2013 Andrew Meyer <ameyer+secure@nodnetwork.org>
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

STEAM=/home/gameservers/hlds/steam
cd /home/gameservers/steamgames/

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
