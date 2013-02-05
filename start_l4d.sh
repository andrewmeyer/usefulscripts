#! /bin/bash
#this program automatically starts a Left 4 Dead 2 server with default configuration settings listed below.

cd /home/gameservers/left4dead/l4d/

./srcds_run l4d  +sv_lan 0  +hostport 27039  +exec server.cfg +map l4d_farm01_hilltop -fork 2
