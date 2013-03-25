#! /bin/sh
#this script makes it easier to start a Garrys Mod server, later versions can take paramaters to customize
#SCRDS_RUN= /home/gameservers/tf/orangebox/srcds_run

cd /home/gameservers/garrysmod/orangebox/
`screen -dmS gm ./srcds_run -game garrysmod  -timeout 30  -debuglog gmdebug.log +port 27015 +map gm_construct +maxplayers 10`

#should start the server in a screen and then detatch it =)
