#! /bin/bash

#
# policychanger.sh
# fixes ownership an permissions on the entire system =)
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

##see if we are running as root
if [ `whoami` != "root" ] ;then
        echo "SCRIPT MUST BE RUN AS ROOT"
        exit 5
fi
echo "fixing permissions in /Users via recursion..."
sleep 1

#lets get started
cd /Users

#find the total number of user directories
echo "counting user directories..."
COUNT=`ls | wc`
MAX=`echo $COUNT | cut -d ' ' -f 1`
echo "$COUNT directories detected"
sleep 1

#lets do the dirty work, parse the list and recurse into directories
NOW=1
   while [ $NOW -le $MAX ]; do
        NAME=`ls | head -n $NOW | tail -n 1`
        echo "Changing ownership of $NAME's files..."
        sleep .2
        sudo chown -Rv $NAME $NAME
        echo "changing permissions to 774 for $NAME's files..."
        sleep .2
        sudo chmod -Rv 774 $NAME

        NOW=$[$NOW+1]
    done
