#!/bin/bash
# Removes all data from the Solr and the OAI-PMH harvesting dir
# which will lead to a full reindex

curl -i -X POST 'http://127.0.0.1:8983/solr/biblio/update?commit=true' --data-binary '<delete><query>*:*</query></delete>' &&\
rm -fR /opt/harvest/alma/* &&\
rm -fR /opt/harvest/degruyter/*
if [ "$?" == "0" ] ; then
    echo "## Data removed successfully"
    echo ""
    echo "Now you can wait until the periodic harvest & index jobs reimport the data."
    echo ""
    echo "If you want to trigger harvesting and indexing manually:"
    echo ""
    echo "* To harvest OAI-PMH records run the following command in the web application docker container:"
    echo "    /var/www/vufind/harvest/health_check_and_harvest.sh"
    echo "* To import harvested records once harvesting ended (!) run the following command in the solr docker container:"
    echo "    /opt/harvest/health_check_and_index.sh 1"
    echo ""
fi
