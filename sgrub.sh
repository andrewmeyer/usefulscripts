#!/bin/bash
# /etc/init.d/minecraft
# version 0.3.6 2011-10-17 (YYYY-MM-DD)

### BEGIN INIT INFO
# Provides:   minecraft
# Required-Start: $local_fs $remote_fs
# Required-Stop:  $local_fs $remote_fs
# Should-Start:   $network
# Should-Stop:    $network
# Default-Start:  2 3 4 5
# Default-Stop:   0 1 6
# Short-Description:    Minecraft server
# Description:    Starts the minecraft server
### END INIT INFO

#Settings
#SERVICE='minecraft_server.jar'
#SERVICE='Tekkit.jar'
SERVICE='SGrub.jar'
PROC="java"
PIDDIR=/var/run/games
SCRN='sgrub'
OPTIONS='nogui'
USERNAME='gameservers'
DEFAULT_WORLD='world'
MCPATH='/home/gameservers/alphasgrub/'
BACKUPPATH='/home/gameservers/alphasgrub/minecraft.backup'
CPU_COUNT=4
INVOCATION="java -Xmx2048M -Xms2048M -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=$CPU_COUNT -XX:+AggressiveOpts -jar $SERVICE $OPTIONS"

AUTOBAK_PATH="/home/gameservers/sgrub/autobak.py"
AUTOBAK_INTERVAL=15
AUTOBAK_ENABLED=".IF I HATE MYSELF SO MUCH, THEN WHY DON'T I HATEMARRY MYSELF?"
AUTOBAK_SCRIPT="/etc/init.d/sgrub" #autobak is hardcoded to call the BACKUP argument, currently

#accept world name or use default value
#if [ -z "$2" ]; then
	WORLD="$DEFAULT_WORLD"
#	echo "no world specified, using default world, '$WORLD'"
#	echo "world name is passed after command"
#else
#		WORLD='$2'
#		echo "using '$WORLD' as world name"
#		echo ""
#fi

ME=`whoami`
as_user() {
  if [ $ME == $USERNAME ] ; then
    bash -c "$1"
  else
    su - $USERNAME -c "$1"
  fi
}

mc_start() {
  if  pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    echo "$SERVICE is already running!"
  else
    echo "Starting $SERVICE..."
    cd $MCPATH
    as_user "cd $MCPATH && screen -dmS $SCRN $INVOCATION"
    sleep 7
    if pgrep -u $USERNAME -f $SERVICE > /dev/null
    then
      echo "$SERVICE is now running."
      INFO=`ps -A | grep "$PROC" | tail -n 1`
      PID=`echo $INFO | cut -d ' ' -f 1`
      echo "$PID" > $PIDDIR/sgrub.pid
      if [ "$AUTOBAK_ENABLED" == "IF I HATE MYSELF SO MUCH, THEN WHY DON'T I HATEMARRY MYSELF?" ]; then
        if [ -e "$AUTOBAK_PATH" ]; then
         echo "Starting AutoBak backup daemon for $SERVICE: $AUTOBAK_PATH $AUTOBAK_INTERVAL $AUTOBAK_SCRIPT $PID"
         "$AUTOBAK_PATH" $AUTOBAK_INTERVAL "$AUTOBAK_SCRIPT" $PID &
        fi
      fi

    else
      echo "Error! Could not start $SERVICE!"
    fi
  fi
}

mc_saveoff() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    echo "$SERVICE is running... suspending saves"
    as_user "screen -p 0 -S $SCRN -X eval 'stuff \"say SERVER BACKUP STARTING. Server going readonly...\"\015'"
    as_user "screen -p 0 -S $SCRN -X eval 'stuff \"save-off\"\015'"
    as_user "screen -p 0 -S $SCRN -X eval 'stuff \"save-all\"\015'"
    sync
    sleep 10
  else
    echo "$SERVICE is not running. Not suspending saves."
  fi
}

mc_saveon() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    echo "$SERVICE is running... re-enabling saves"
    as_user "screen -p 0 -S $SCRN -X eval 'stuff \"save-on\"\015'"
    as_user "screen -p 0 -S $SCRN -X eval 'stuff \"say SERVER BACKUP ENDED. Server going read-write...\"\015'"
  else
    echo "$SERVICE is not running. Not resuming saves."
  fi
}

mc_stop() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    echo "Stopping $SERVICE"
    as_user "screen -p 0 -S $SCRN -X eval 'stuff \"say SERVER SHUTTING DOWN IN 10 SECONDS. Saving map...\"\015'"
    as_user "screen -p 0 -S $SCRN -X eval 'stuff \"save-all\"\015'"
    sleep 10
    as_user "screen -p 0 -S $SCRN -X eval 'stuff \"stop\"\015'"
    sleep 7
  else
    echo "$SERVICE was not running."
  fi
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    echo "Error! $SERVICE could not be stopped."
  else
    echo "$SERVICE is stopped."
    rm $PIDDIR/sgrub.pid
  fi
}

mc_update() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    echo "$SERVICE is running! Will not start update."
  else
    MC_SERVER_URL=http://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar?v=`date | sed "s/[^a-zA-Z0-9]/_/g"`
    as_user "cd $MCPATH && wget -q -O $MCPATH/minecraft_server.jar.update $MC_SERVER_URL"
    if [ -f $MCPATH/minecraft_server.jar.update ]
    then
      if `diff $MCPATH/$SERVICE $MCPATH/minecraft_server.jar.update >/dev/null`
      then 
        echo "You are already running the latest version of $SERVICE."
      else
        as_user "mv $MCPATH/minecraft_server.jar.update $MCPATH/$SERVICE"
        echo "Minecraft successfully updated."
      fi
    else
      echo "Minecraft update could not be downloaded."
    fi
  fi
}

mc_backup() {
   echo "Backing up minecraft world..."
   if [ -d $BACKUPPATH/${WORLD}_`date "+%Y.%m.%d_%H.%M"` ]
   then
     for i in 1 2 3 4 5 6
     do
       if [ -d $BACKUPPATH/${WORLD}_`date "+%Y.%m.%d_%H.%M"`-$i ]
       then
         continue
       else
         as_user "cd $MCPATH && cp -rv $WORLD/ $BACKUPPATH/${WORLD}_`date "+%Y.%m.%d_%H.%M"`-$i"
	 as_user "cd $MCPATH && cp -rv ${WORLD}_nether/ $BACKUPPATH/${WORLD}_nether_`date "+%Y.%m.%d_%H.%M"`-$i"
	 as_user "cd $MCPATH && cp -rv ${WORLD}_the_end/ $BACKUPPATH/${WORLD}_the_end_`date "+%Y.%m.%d_%H.%M"`-$i"
         break
       fi
     done
   else
     as_user "cd $MCPATH && cp -rv $WORLD/ $BACKUPPATH/${WORLD}_`date "+%Y.%m.%d_%H.%M"`"
     as_user "cd $MCPATH && cp -rv ${WORLD}_nether/ $BACKUPPATH/${WORLD}_nether_`date "+%Y.%m.%d_%H.%M"`-$i"
     as_user "cd $MCPATH && cp -rv ${WORLD}_the_end/ $BACKUPPATH/${WORLD}_the_end_`date "+%Y.%m.%d_%H.%M"`-$i"
     echo "Backed up world"
   fi
#   echo "Backing up $SERVICE"
#   if [ -f "$BACKUPPATH/minecraft_server_`date "+%Y.%m.%d_%H.%M"`.jar" ]
#   then
#     for i in 1 2 3 4 5 6
#     do
#       if [ -f "$BACKUPPATH/minecraft_server_`date "+%Y.%m.%d_%H.%M"`-$i.jar" ]
#       then
#         continue
#       else
#         as_user "cd $MCPATH && cp -v $SERVICE \"$BACKUPPATH/minecraft_server_`date "+%Y.%m.%d_%H.%M"`-$i.jar\""
#         break
#       fi
#     done
#   else
#     as_user "cd $MCPATH && cp  -v $SERVICE \"$BACKUPPATH/minecraft_server_`date "+%Y.%m.%d_%H.%M"`.jar\""
#   fi

#  echo "Backup up Mods folder..."
#	as_user "cd $MCPATH && cp -Rv mods $BACKUPPATH/
   echo "Backup complete"
}

mc_command() {
  command="$1";
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
  then
    pre_log_len=`wc -l "$MCPATH/server.log" | awk '{print $1}'`
    echo "$SERVICE is running... executing command"
    as_user "screen -p 0 -S $SCRN -X eval 'stuff \"$command\"\015'"
    sleep .1 # assumes that the command will run and print to the log file in less than .1 seconds
    # print output
    tail -n $[`wc -l "$MCPATH/server.log" | awk '{print $1}'`-$pre_log_len] "$MCPATH/server.log"
  fi
}

#Start-Stop here
case "$1" in
  start)
    mc_start
    ;;
  stop)
    mc_stop
    ;;
  restart)
    mc_stop
    mc_start
    ;;
  update)
    mc_stop
    mc_backup
    mc_update
    mc_start
    ;;
  backup)
    mc_saveoff
    mc_backup
    mc_saveon
    ;;
  status)
    if pgrep -u $USERNAME -f $SERVICE > /dev/null
    then
      echo "$SERVICE is running."
    else
      echo "$SERVICE is not running."
    fi
    ;;
  command)
    if [ $# -gt 1 ]; then
      shift
      mc_command "$*"
    else
      echo "Must specify server command (try 'help'?)"
    fi
    ;;

  *)
  echo "Usage: /etc/init.d/sgrub {start|stop|update|backup|status|restart|command \"server command\"}"
  exit 1
  ;;
esac

exit 0
