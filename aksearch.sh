#!/bin/bash
if [ ! -d /opt/solr/server/solr/mycores/biblio ]; then
    echo "AkSearch cores missing - initializing"
    cp -R /opt/aksearch/* /opt/solr/server/solr/mycores/
    mv /opt/solr/server/solr/mycores/solr.xml /opt/solr/server/solr/solr.xml
fi

