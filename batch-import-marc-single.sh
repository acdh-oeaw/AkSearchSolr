#!/bin/bash
STATE=`ps ax | grep batch-import-marc | wc -l`
echo "--------------------------------"
date
if [ "$STATE" == "1" ] ; then
    /opt/aksearch/harvest/batch-import-marc.sh "$@"
else
    echo "batch-import-marc.sh is already running"
fi
