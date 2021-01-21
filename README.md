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

* if you want to import a single file: `cd /opt/aksearch && ./import-marc.sh pathToTheMarcFile`
* if you want to import all files in a directory: `cd /opt/aksearch/harvest && ./batch-import-marc.sh -m -d pathToTheMarcDir`

### Using own MARC import.properties

Just mount it into the container and set the `VUFIND_LOCAL_DIR` environment variable in a way `$VUFIND_LOCAL_DIR/import/import.properties` points to your MARC import properties file, e.g.:

```bash
docker run --name aksearch-solr -d -p 8983:8983 -v aksearch-solrdata:/opt/solr/server/solr/mycores \
  -v pathToMyLocalImport.properties:/opt/localcfg/import/import.properties -e VUFIND_LOCAL_DIR=/opt/localcfg \
  acdhch/aksearch-solr
```

For `import_auth.properties` do the same, just adjust what/where you mount accordingly.

Be aware Solr in this configuration Solr works on port 8983, which might require adjusting of the `solr.hosturl` configuration property in your import.properties file.
