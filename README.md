# AkSearchSolr

Docker image of a Solr instance ready to be used as an [AkSearch](https://biapps.arbeiterkammer.at/gitlab/open/aksearch/aksearch) Solr backend and MARC data import environment.

As in `solr:7` the Solr is installed in `/opt/solr/server/solr`.

AkSearch repository is cloned into `/opt/aksearch`. 
`/opt/aksearch/import/*properties` files have Solr port fixed (AkSearch assumes Solr works on port 8080 while by default it works on 8983).

Run with with e.g.:

```bash
docker run --name aksearch-solr -d -p 8983:8983 -v aksearch-solrdata:/opt/solr/server/solr/mycores acdhch/aksearch-solr
```

## Importing MARC data

Enter container, e.g. with `docker exec -ti aksearch-solr bash` and:

* If you want to import a single file: `cd /opt/aksearch && ./import-marc.sh pathToTheMarcFile`.
* If you want to import all files in a directory: `cd /opt/aksearch/harvest && ./batch-import-marc.sh -m -d pathToTheMarcDir`.  
  Be aware the `batch-import-marc.sh` script writes logs into `pathToTheMarcDir/log` directory by default and fails if it's unable to create/write to this dir. If you run into such trouble consider using the `-z` switch to turn off logging to files (and you will still get log on the console and you can redirect it to a file).

Similarly you can use other import scripts shipped with AkSearch (`/opt/aksearch/harvest/batch-import-marc-auth.sh`, `/opt/aksearch/import-marc-auth.sh` and others).

### Using own MARC import.properties

Just mount it into the container and set the `VUFIND_LOCAL_DIR` environment variable in a way `$VUFIND_LOCAL_DIR/import/import.properties` points to your MARC import properties file, e.g.:

```bash
docker run --name aksearch-solr -d -p 8983:8983 -v aksearch-solrdata:/opt/solr/server/solr/mycores \
  -v pathToMyLocalImport.properties:/opt/localcfg/import/import.properties -e VUFIND_LOCAL_DIR=/opt/localcfg \
  acdhch/aksearch-solr
```

Act accordingly for any other configuration file.

**Be aware in this configuration Solr works on port 8983** which might require adjusting of the `solr.hosturl` configuration property in your import.properties file.
