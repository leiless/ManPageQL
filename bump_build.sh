#!/bin/sh
#
# Created 190220 lynnl
#
# Script used to tracking build number
#

set -e
#set -x

DIR=/var/tmp/.bundle_build_number
HASH=$(git rev-list --max-parents=0 HEAD)

mkdir -p $DIR
cd $DIR

if [ -f $HASH ]; then
    OLD=$(cat $HASH)
    NEW=$(expr $OLD + 1)
else
    OLD=0
    NEW=0
fi

printf $NEW > $HASH
printf $OLD

