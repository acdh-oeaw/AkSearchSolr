## Import Workflow

* copy relevant data to `\\w07ds5\OeAW_Projekte01$\ACDH-CH_BASIS_METADATA_CURATION`
* login to https://rancher.acdh-dev.oeaw.ac.at
* navigate to deployment - https://rancher.acdh-dev.oeaw.ac.at/dashboard/c/c-m-6hwgqq2g/explorer/apps.deployment
* execute shell
```bash
# navigate to aksearch folder
cd /opt/aksearch
#import relevant set
harvest/batch-import-marc.sh -d -p /opt/local/import/import_bib_alma.properties /opt/harvest/manual/oxford
```