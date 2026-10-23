FROM solr:9.5
USER root
RUN apt update &&\
    apt install -y git default-jdk-headless vim &&\
    apt clean
RUN git clone --depth 1 -b v10.1.1 https://github.com/vufind-org/vufind.git /opt/vufind &&\
    ln -s /opt/solr /opt/vufind/solr/vendor &&\
    # solr in the solr:9 image refuses to load jars from /opt/vufind/(...) so we can just put all of them into $SOLR_HOME/jars\
    cp /opt/vufind/import/solrmarc_core*.jar /opt/vufind/import/lib/marc4j*.jar /opt/vufind/solr/vufind/jars/ &&\
    sed -i -e '/<lib.*import/d' /opt/vufind/solr/vufind/biblio/conf/solrconfig.xml &&\
    # in the solr:9 image SOLR_HOME=/var/solr/data while code and libs is in /opt/solr - fix the reference \
    sed -i -e 's@../../vendor/modules/@/opt/solr/modules/@g' /opt/vufind/solr/vufind/biblio/conf/solrconfig.xml &&\
    # to avoid issues with the cluster storage \
    sed -i -e 's@<indexConfig>$@<indexConfig>\n    <lockType>single</lockType>\n@g' /opt/vufind/solr/vufind/biblio/conf/solrconfig.xml &&\
    sed -i -e 's@:8080/solr/@:8983/solr/@g' /opt/vufind/import/*properties &&\
    sed -i -e 's@^RUN_CMD="[$]JAVA @RUN_CMD="$JAVA $GC_TUNE @g' /opt/vufind/import-marc.sh
COPY init_solr.sh /docker-entrypoint-initdb.d/init_solr.sh
COPY vufind /opt/vufind
COPY local /opt/local
RUN mkdir /opt/harvest &&\
    chown -R $SOLR_USER /opt/vufind /opt/harvest /opt/local /opt/solr*
ENV VUFIND_LOCAL_DIR=/opt/local JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 SOLR_JAVA_MEM='-Xms2g' OOM=script GC_TUNE='-XX:+UnlockExperimentalVMOptions -XX:+UseContainerSupport -XX:MaxRAMFraction=1 -XX:+UseShenandoahGC -XX:ShenandoahGCHeuristics=compact -XX:+UseStringDeduplication'
USER $SOLR_USER
