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
* If you want to import all files in a directory: `cd /opt/aksearch && harvest/batch-import-marc.sh -m -d pathToTheMarcDir`.  
    *  Be aware the `batch-import-marc.sh` script writes logs into `pathToTheMarcDir/log` directory by default and fails if it's unable to create/write to this dir. If you run into such trouble consider using the `-z` switch to turn off logging to files (and you will still get log on the console and you can redirect it to a file).
    * The `/opt/aksearch/harvest/batch-import-marc-single.sh` wrapper assures the import isn't run until the previous one finished.

Similarly you can use other import scripts shipped with AkSearch (`/opt/aksearch/harvest/batch-import-marc-auth.sh`, `/opt/aksearch/import-marc-auth.sh` and others).

### Importing sample MARC data

* Login into running container, e.g. `docker exec -ti aksearch-solr bash`.
* Download, decompress and import sample data:
  ```bash
  curl -L 'https://github.com/acdh-oeaw/AkSearchSolr/blob/main/.github/workflows/marc.xml.gz?raw=true' > /tmp/marc.xml.gz
  gunzip /tmp/marc.xml.gz
  cd /opt/aksearch && ./import-marc.sh /tmp/marc.xml
  rm /tmp/marc.xml
  ```
* Exit the container with `exit`.

### Importing complete test dataset

* Log into the running container as root, e.g. `docker exec -u root -ti aksearch-solr bash`.
* Download the dataset over OAI-PMH using the `VuFindMinimal` set and make it look like the VuFind download script results:
  ```bash
  curl 'https://eu02.alma.exlibrisgroup.com/view/oai/43ACC_OEAW/request?metadataPrefix=marc21&verb=ListRecords&set=VuFindMinimal' | tail -n +5 | grep -v '^</metadata>' > /tmp/records.xml
  echo "<collection>" > /tmp/records2.xml
  cat /tmp/records.xml >> /tmp/records2.xml
  echo "</collection>" >> /tmp/records2.xml
  mv /tmp/records2.xml /tmp/records.xml
  ```
* Import the data with
  ```bash
  /opt/aksearch/import-marc.sh /tmp/records.xml
  ```

### Importing a given Alma record

* Find Alma record's MMS_ID
* Log into the running container as root, e.g. `docker exec -u root -ti aksearch-solr bash`.
* Download the record over OAI-PMH skipping the OAI-PMH envelope:
  ```bash
  curl 'https://eu02.alma.exlibrisgroup.com/view/oai/43ACC_OEAW/request?metadataPrefix=marc21&verb=GetRecord&identifier=oai:alma.43ACC_OEAW:{MMS_ID}' | tail -n 2 | head -n 1 > /tmp/record.xml
  ```
  e.g.
  ```bash
  curl 'https://eu02.alma.exlibrisgroup.com/view/oai/43ACC_OEAW/request?metadataPrefix=marc21&verb=GetRecord&identifier=oai:alma.43ACC_OEAW:993516214704498' | tail -n 2 | head -n 1 > /tmp/record.xml
  ```
* Import the record with
  ```bash
  /opt/aksearch/import-marc.sh /tmp/record.xml
  ```

### Using own MARC import.properties

Just mount it into the container and set the `VUFIND_LOCAL_DIR` environment variable in a way `$VUFIND_LOCAL_DIR/import/import.properties` points to your MARC import properties file, e.g.:

```bash
docker run --name aksearch-solr -d -p 8983:8983 -v aksearch-solrdata:/opt/solr/server/solr/mycores \
  -v pathToMyLocalImport.properties:/opt/localcfg/import/import.properties -e VUFIND_LOCAL_DIR=/opt/localcfg \
  acdhch/aksearch-solr
```

Act accordingly for any other configuration file.

### Known issues

* This image runs Solr on port 8983. If you are using your own `import.properties` file, you may need to adjust the `solr.hosturl` configuration property.
* If `batch-import-marc-auth.sh` gives you
  ```
  FATAL [main] (Boot.java:215) - ERROR: Error while invoking main method in specified class: org.solrmarc.driver.IndexDriver
  java.lang.LinkageError: loader org.solrmarc.driver.Boot @3fee733d attempted duplicate interface definition for org.ini4j.Persistable. (org.ini4j.Persistable is in unnamed module of loader org.solrmarc.driver.Boot @3fee733d, parent loader 'app')
  ```
  it means it messed up with paths.   
  Running `batch-import-marc.sh` from the directory where `import-marc.sh` should solve the issue (see examples above - `cd /opt/aksearch` and then `harvest/batch-import-marc.sh -m -d pathToTheMarcDir`).
    * The precise reason is stated in logs a few lines above and looks more or less like that:
      ```
      DEBUG [main] (Boot.java:645) - Number of homeDirStrs: 3
      DEBUG [main] (Boot.java:648) - homeDirStrs[0]: /usr/local/vufind/import
      DEBUG [main] (Boot.java:652) - homeDirStrs[1]: /opt/aksearch/harvest/../import
      ```
      The issue here is that the third homeDirStrs (which isn't printed in the log) is the `import-marc.sh` directory and it duplicates with `/opt/aksearch/harvest/../import` leading to duplicated class imports.
