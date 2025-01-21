FROM solr:9.5
USER root
RUN apt update &&\
    apt install -y git default-jdk-headless vim &&\
    apt clean &&\
    mkdir -p /opt/aksearch /opt/harvest &&\
    chown $SOLR_USER /opt/aksearch /opt/harvest
ENV VUFIND_LOCAL_DIR=/opt/local JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 SOLR_JAVA_MEM='-Xms2g' OOM=script GC_TUNE='-XX:+UnlockExperimentalVMOptions -XX:+UseContainerSupport -XX:MaxRAMFraction=1 -XX:+UseShenandoahGC -XX:ShenandoahGCHeuristics=compact -XX:+UseStringDeduplication'
USER $SOLR_USER
RUN git clone -b aksearch10 --depth 1 https://github.com/acdh-oeaw/aksearch.git /opt/aksearch &&\
    ln -s /opt/solr /opt/aksearch/solr/vendor &&\
    # solr in the solr:9 image refuses to load jars from /opt/aksearch/(...) so we can just put all of them into $SOLR_HOME/jars\
    cp /opt/aksearch/import/solrmarc_core*.jar /opt/aksearch/import/lib/marc4j*.jar /opt/aksearch/solr/vufind/jars/ &&\
    sed -i -e '/<lib.*import/d' /opt/aksearch/solr/vufind/biblio/conf/solrconfig.xml &&\
    # in the solr:9 image SOLR_HOME=/var/solr/data while code and libs is in /opt/solr - fix the reference \
    sed -i -e 's@../../vendor/modules/@/opt/solr/modules/@g' /opt/aksearch/solr/vufind/biblio/conf/solrconfig.xml &&\
    # to avoid issues with the cluster storage \
    sed -i -e 's@<indexConfig>$@<indexConfig>\n    <lockType>single</lockType>\n@g' /opt/aksearch/solr/vufind/biblio/conf/solrconfig.xml &&\
    sed -i -e 's@:8080/solr/@:8983/solr/@g' /opt/aksearch/import/*properties &&\
    sed -i -e 's@^RUN_CMD="[$]JAVA @RUN_CMD="$JAVA $GC_TUNE @g' /opt/aksearch/import-marc.sh
# To be able to run on ACDH cluster with SOLR_HOME being an NFS mount with the .rmtab
# Remark - this script does not exist in the solr >7 images
#RUN sed -i -e 's/lost+found/& ! -name .rmtab/' /opt/docker-solr/scripts/init-solr-home
COPY aksearch.sh /docker-entrypoint-initdb.d/aksearch.sh
COPY batch-import-marc-single.sh /opt/aksearch/harvest/batch-import-marc-single.sh
COPY health_check_and_index.sh /opt/harvest/health_check_and_index.sh
COPY oeaw_reindex.sh /opt/harvest/oeaw_reindex.sh
COPY local /opt/local
COPY java_helpers/Oeaw.java /opt/aksearch/import/index_java/src/Oeaw.java
