GAME_SYS_PATH=/home/gameservers/redorchestra/system/
GAME_RUNTIME="ucc-bin-real"

echo "Detecting if $GAME_RUNTIME is already running..."

ISRUNNING=`pidof $GAME_RUNTIME`

if [ -z $ISRUNNING ]; then
        echo "$GAME_RUNTIME is not running."
else
        echo "$GAME_RUNTIME is running [PID: $ISRUNNING].  "
        echo "Having multiple instances of UT servers will create 
conflicts of epic proportions.  Terminate $GAME_RUNTIME ? (y/n/[Ctrl+C 
to abort]):"
        read input
        if [ "$input" == "y" ]; then
                echo "Terminating instance(s)"
                killall $GAME_RUNTIME
        else
                echo "Not Terminating. I hope you have a segfault 
bunker!"
        fi
fi
echo "Starting server..."
cd $GAME_SYS_PATH
#./ucc-bin server RO-Konigsplatz.rom?game-ROEngine.ROTeamGame?deathmessagemode=DM_ALL?VACSecure=true ini=/home/gameservers/redorchestra/system/RedOrchestra.ini -log=ServerLog.log -nohomedir &
#./ucc-bin server RO-Konigsplatz?game=ROGame.ROTeamGame -log=RO_Server.log ini=/home/gameservers/redorchestra/system/RedOrchestra.ini -VACSecure=true -nohomedir &
screen -dmS RO ./ucc-bin server RO-Konigsplatz.rom?deathmessagemode=3?PreStartTime=60?RoundLimit=3?WinLimit=2?TimeLimit=0?VACSecure=true?game=ROEngine.ROTeamGame? ini=RedOrchestra.ini -log=ServerLog.log -nohomedir &
