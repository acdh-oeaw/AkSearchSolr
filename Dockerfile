FROM solr:7
USER root
RUN apt update &&\
    apt install -y git &&\
    apt clean &&\
    mkdir /opt/aksearch &&\
    chown $SOLR_USER /opt/aksearch
USER $SOLR_USER
RUN git clone --depth 1 https://biapps.arbeiterkammer.at/gitlab/open/aksearch/aksearch.git /opt/aksearch/git &&\
    mv /opt/aksearch/git/solr/vufind/* /opt/aksearch/ &&\
    rm -fR /opt/aksearch/git &&\
    sed -i -e 's@../../vendor/@/opt/solr/@g' /opt/aksearch/biblio/conf/solrconfig.xml
COPY aksearch.sh /docker-entrypoint-initdb.d/aksearch.sh

