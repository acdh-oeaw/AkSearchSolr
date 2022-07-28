FROM solr:7
USER root
RUN apt update &&\
    apt install -y git openjdk-11-jdk-headless vim &&\
    apt clean &&\
    mkdir -p /opt/aksearch /opt/harvest &&\
    chown $SOLR_USER /opt/aksearch /opt/harvest
ENV VUFIND_LOCAL_DIR=/opt/local JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 SOLR_JAVA_MEM='-Xms2g' OOM=script GC_TUNE='-XX:+UnlockExperimentalVMOptions -XX:+UseContainerSupport -XX:MaxRAMFraction=1 -XX:+UseShenandoahGC -XX:ShenandoahGCHeuristics=compact -XX:+UseStringDeduplication'
USER $SOLR_USER
RUN git clone --depth 1 https://biapps.arbeiterkammer.at/gitlab/open/aksearch/aksearch.git /opt/aksearch &&\
    ln -s /opt/solr /opt/aksearch/solr/vendor &&\
    sed -i -e 's@../../vendor/@/opt/solr/@g' /opt/aksearch/solr/vufind/biblio/conf/solrconfig.xml &&\
    sed -i -e 's@:8080/solr/@:8983/solr/@g' /opt/aksearch/import/*properties &&\
    sed -i -e 's@^RUN_CMD="[$]JAVA @RUN_CMD="$JAVA $GC_TUNE @g' /opt/aksearch/import-marc.sh
# to be able to run on ACDH cluster with SOLR_HOME being an NFS mount with the .rmtab
RUN sed -i -e 's/lost+found/& ! -name .rmtab/' /opt/docker-solr/scripts/init-solr-home
COPY aksearch.sh /docker-entrypoint-initdb.d/aksearch.sh
COPY batch-import-marc-single.sh /opt/aksearch/harvest/batch-import-marc-single.sh
COPY health_check_and_index.sh /opt/harvest/health_check_and_index.sh
COPY oeaw_reindex.sh /opt/harvest/oeaw_reindex.sh
COPY local /opt/local
COPY java_helpers/Oeaw.java /opt/aksearch/import/index_java/src/Oeaw.java
