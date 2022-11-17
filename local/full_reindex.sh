#!/bin/bash

SET=$1
echo "Resetting Core"
curl -i -X POST 'http://127.0.0.1:8983/solr/biblio/update?commit=true' --data-binary '<delete><query>*:*</query></delete>' &&\

echo "Starting Indexing"
cd /opt/aksearch && harvest/batch-import-marc.sh -m -d -p /opt/local/import/import_$SET.properties /opt/harvest/$SET