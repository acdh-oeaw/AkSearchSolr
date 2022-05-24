#!/bin/bash

SET=$1
echo "Resetting Core"
curl --request POST -sL \
     --url 'http://localhost:8983/api/cores/biblio/config'\
     -d '{"set-property": [{"requestDispatcher.requestParsers.enableRemoteStreaming": true},{"requestDispatcher.requestParsers.enableStreamBody": true}]}'\
     -H "Content-Type: application/json"

curl --request GET -sL \
     --url 'http://localhost:8983/solr/biblio/update?stream.body=<delete><query>*:*</query></delete>&commit=true'

echo "Starting Indexing"
cd /opt/aksearch && harvest/batch-import-marc.sh -m -d /opt/harvest/$SET



