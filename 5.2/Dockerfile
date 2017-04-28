FROM baselibrary/java:8
MAINTAINER ShawnMa <qsma@thoughtworks.com>

## Version
ENV ELASTICSEARCH_MAJOR   5.2
ENV ELASTICSEARCH_VERSION 5.2.2

## Repository
RUN \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D88E42B4 &&\
  echo "deb http://artifacts.elastic.co/packages/5.x stable main" > /etc/apt/sources.list.d/elasticsearch.list

## Packages
RUN \
  apt-get update &&\
  apt-get install -y elasticsearch=$ELASTICSEARCH_VERSION &&\
  rm -rf /var/lib/apt/lists/*

## Environments
ENV PATH /usr/share/elasticsearch/bin:$PATH

## Scripts
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod a+x            /docker-entrypoint.sh

EXPOSE 9200 9300

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME ["/usr/share/elasticsearch/data"]

CMD ["elasticsearch"]
