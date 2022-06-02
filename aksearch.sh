#!/bin/bash
SOLR_HOME=${SOLR_HOME:=/opt/solr/server/solr}
if [ ! -d /opt/solr/server/solr/mycores/biblio ]; then
    echo "AkSearch cores missing - initializing"
    cp -R /opt/aksearch/solr/vufind/* "$SOLR_HOME/mycores/"
    mv "$SOLR_HOME/mycores/solr.xml" "$SOLR_HOME/solr.xml"
fi

