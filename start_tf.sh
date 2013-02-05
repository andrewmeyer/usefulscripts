#! /bin/sh
#this script makes it easier to start a TF2 server, later versions can take paramaters to customize
#SCRDS_RUN= /home/gameservers/tf/orangebox/srcds_run
echo "Performing pre run update check..."
sleep 1

update tf

sleep 1
echo "Update check completed..."
sleep 1
echo "Starting Team Fortress 2 server..."

cd /home/gameservers/tf/orangebox/
`screen -dmS tf ./srcds_run -game tf  -timeout 30  -debuglog tf2debug.log +map koth_viaduct +port 27015 +maxplayers 24`
sleep 10

echo "Startup procedures completed, server running in screen 'tf'"
echo "Check server logs for additional information"
sleep 1
#should start the server in a screen and then detatch it =)
