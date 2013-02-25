#! /bin/bash
# syncNpack 1.0 written for NodNetwork by Andrew Meyer
#Needs: zip
#Needs: git

if [ ! -x zip ] ;then
        echo "FATAL: Zip does not appear to be installed or you cannot run it"
        exit 2
fi
fi
if [ ! -x git ] ;then
        echo "FATAL: Git does not appear to be installed or you cannot run it"
        exit 2
fi

GITDIR=/home/scmeyer/github/nodpak/
ZIPFILE=/home/ftp/minecraft/nodpak2.zip
MAKEPATCH=false

if [ ! -d $GITDIR ] ;then
        echo "FATAL: $GITDIR does not exist or is not readable"
        exit 2
fi
		
if [ ! -w $ZIPFILE ] ;then
        echo "FATAL: $ZIPFILE does not exist or is not writable"
        exit 2
fi

cd $GITDIR
echo "starting sync"
git pull
sleep 1

#add check that if no updates found, exit 0 later
# perhaps dump lot of git (may need tor patch maker)

echo "beginning zipfile update"
zip -vrf $ZIPFILE *
sleep 1

#email changes to zip to an admin

echo "syncNpack completed"
