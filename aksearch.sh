#!/bin/bash
SOLR_HOME=${SOLR_HOME:=/var/solr/data}
if [ ! -d "$SOLR_HOME/biblio" ]; then
    echo "Vufind cores missing - initializing"
    cp -R /opt/aksearch/solr/vufind/* "$SOLR_HOME/"
fi

