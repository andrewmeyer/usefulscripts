#! /bin/bash
# syncNpack 1.0 written for NodNetwork by Andrew Meyer
#Needs: zip
#Needs: git

#write dependency check for zip later

#write dependency check for git later

GITDIR=/home/scmeyer/github/nodpak/
ZIPFILE=/home/ftp/tekkit/nodpak2.zip
MAKEPATCH=false
#write dependency check for GITDIR later

#write dependency check for ZIPFILE later

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
