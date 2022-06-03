#!/bin/bash
curl http://127.0.0.1:8983/solr/ > /dev/null 2>&1
RET=$?

# minutes since last activity in the directory to start indexing
DELAY=$1
DELAY=${DELAY:=10}

if [ "`find /opt/harvest/alma -maxdepth 0 -mmin -$DELAY`" == "" ] && [ "`find /opt/harvest/alma -maxdepth 1 -name *xml | wc -l`" != "0" ] ; then
    nohup /opt/aksearch/harvest/batch-import-marc-single.sh -d /opt/harvest/alma > /opt/harvest/alma.log 2>&1
fi
if [ "`find /opt/harvest/degruyter -maxdepth 0 -mmin -$DELAY`" == "" ] && [ "`find /opt/harvest/degruyter -maxdepth 1 -name *xml | wc -l`" != "0" ] ; then
    #nohup /opt/aksearch/harvest/batch-import-marc-single.sh -d /opt/harvest/degruyter > /opt/harvest/degruyter.log 2>&1
    echo "degruyter import not defined yet"
fi

exit $RET

