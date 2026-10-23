#!/bin/bash
STATE=`ps ax | grep batch-import-marc.sh | wc -l`
echo "--------------------------------"
date
if [ "$STATE" == "1" ] ; then
    /opt/vufind/harvest/batch-import-marc.sh "$@"
else
    echo "batch-import-marc.sh is already running"
fi
