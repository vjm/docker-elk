FROM dockerfile/java:oracle-java8
MAINTAINER Vince Montalbano <vince.montalbano@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y supervisor curl wget

# Elasticsearch
RUN \
    wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
    if ! grep "elasticsearch" /etc/apt/sources.list; then echo "deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main" >> /etc/apt/sources.list;fi && \
    if ! grep "logstash" /etc/apt/sources.list; then echo "deb http://packages.elasticsearch.org/logstash/1.4/debian stable main" >> /etc/apt/sources.list;fi && \
    apt-get update

RUN \
    apt-get install -y elasticsearch && \
    apt-get clean && \
    sed -i '/#cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml && \
    sed -i '/#path.data: \/path\/to\/data/a path.data: /data1' /etc/elasticsearch/elasticsearch.yml && \
    /usr/share/elasticsearch/bin/plugin -i lmenezes/elasticsearch-kopf/latest
    # && \
    # /usr/share/elasticsearch/bin/plugin -i elasticsearch/marvel/latest && \
    # echo 'marvel.agent.enabled: true' >> ./config/elasticsearch.yml

ADD etc/supervisor/conf.d/elasticsearch.conf /etc/supervisor/conf.d/elasticsearch.conf

# Logstash
RUN apt-get install -y logstash && \
    apt-get install -y logstash-contrib && \
    apt-get clean

ADD etc/supervisor/conf.d/logstash.conf /etc/supervisor/conf.d/logstash.conf

ADD etc/logstash/conf.d /etc/logstash/conf.d

# Kibana
RUN \
    curl -s https://download.elasticsearch.org/kibana/kibana/kibana-4.0.0-linux-x64.tar.gz | tar -C /opt -xz && \
    ln -s /opt/kibana-4.0.0-linux-x64 /opt/kibana
    # && \
    # sed -i 's/port: 5601/port: 80/' /opt/kibana/config/kibana.yml

ADD opt/kibana/src/.htpasswd /opt/kibana/src/.htpasswd

ADD etc/supervisor/conf.d/kibana.conf /etc/supervisor/conf.d/kibana.conf

VOLUME '/data1'

EXPOSE 80 5601 443 9200 9292 9998 9999 9988 9989 5000

CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]
