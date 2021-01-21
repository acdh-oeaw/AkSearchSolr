# AkSearchSolr

Docker image of a Solr instance ready to be used as an [AkSearch](https://biapps.arbeiterkammer.at/gitlab/open/aksearch/aksearch) backend.

It's just a [solr:7](https://hub.docker.com/_/solr) image checking if the AkSearch cores exist and creating them if needed.

As in standard `solr:7` image the Solr is installed in `/opt/solr/server/solr`.
AkSearch Solr core templates can be found in `/opt/aksearch`.

Run with with e.g.:

```bash
docker run --name aksearch-solr -d -p 8983:8983 -v aksearch-solrdata:/opt/solr/server/solr/mycores acdhch/aksearch-solr
```
