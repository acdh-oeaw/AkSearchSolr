FROM solr:7
USER root
RUN apt update &&\
    apt install -y git openjdk-11-jdk-headless &&\
    apt clean &&\
    mkdir /opt/aksearch &&\
    chown $SOLR_USER /opt/aksearch
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
USER $SOLR_USER
RUN git clone --depth 1 https://biapps.arbeiterkammer.at/gitlab/open/aksearch/aksearch.git /opt/aksearch &&\
    ln -s /opt/solr /opt/aksearch/solr/vendor &&\
    sed -i -e 's@../../vendor/@/opt/solr/@g' /opt/aksearch/solr/vufind/biblio/conf/solrconfig.xml &&\
    sed -i -e 's@:8080/solr/@:8983/solr/@g' /opt/aksearch/import/*properties
COPY aksearch.sh /docker-entrypoint-initdb.d/aksearch.sh

