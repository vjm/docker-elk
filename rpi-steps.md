sudo apt-get install -y supervisor

sudo mkdir /usr/share/elasticsearch
cd /usr/share/elasticsearch

sudo wget https://download.elasticsearch.org/kibana/kibana/kibana-4.0.1-linux-x64.tar.gz
sudo wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.4.tar.gz
sudo wget https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz

sudo tar -zxvf elasticsearch-0.90.0.tar.gz
sudo rm elasticsearch-0.90.0.tar.gz


sudo cp /usr/share/elasticsearch/elasticsearch-1.4.4/config/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

sudo sed -i '/#cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml
sudo sed -i '/#path.data: \/path\/to\/data/a path.data: /mnt/TimeCapsule1/raspberrypi/elk/data/' /etc/elasticsearch/elasticsearch.yml

sudo mv elasticsearch-1.4.4/* .
sudo rmdir elasticsearch-1.4.4/

# sudo /usr/share/elasticsearch/elasticsearch-1.4.4/bin/elasticsearch
# curl -XGET http://10.0.1.32:9200/

sudo tar -zxvf logstash-1.4.2.tar.gz
sudo mv logstash-1.4.2 /opt/logstash-1.4.2
sudo ln -s /opt/logstash-1.4.2 /opt/logstash
sudo mkdir -p /etc/logstash/conf.d
sudo cp /mnt/TimeCapsule1/raspberrypi/etc/logstash/conf.d/* /etc/logstash/conf.d/
sudo mkdir -p /var/log/logstash/

# https://github.com/jruby/jruby/issues/1561
cd /tmp/
sudo git clone https://github.com/jnr/jffi.git
cd jffi/
sudo apt-get install -y ant
sudo ant jar
sudo mkdir -p /opt/logstash-1.4.2/vendor/jar/jni/arm-Linux/
sudo cp /tmp/jffi/build/jni/libjffi-1.2.so /opt/logstash-1.4.2/vendor/jar/jni/arm-Linux/
sudo apt-get install zip
cd /opt/logstash-1.4.2/vendor/jar
sudo zip -g jruby-complete-1.7.11.jar jni/arm-Linux/libjffi-1.2.so

# USE_JRUBY=1 LS_HEAP_SIZE=64m ./bin/logstash -e 'input { stdin { } } output { stdout { } }'



sudo tar -zxvf kibana-4.0.1-linux-x64.tar.gz
sudo mv kibana-4.0.1-linux-x64 /opt/kibana-4.0.1-linux-x64
sudo rm kibana-4.0.1-linux-x64.tar.gz

sudo ln -s /opt/kibana-4.0.1-linux-x64 /opt/kibana

sudo wget http://node-arm.herokuapp.com/node_latest_armhf.deb
sudo dpkg -i node_latest_armhf.deb
sudo mv /opt/kibana/node/bin/node /opt/kibana/node/bin/node.orig
sudo mv /opt/kibana/node/bin/npm /opt/kibana/node/bin/npm.orig
sudo ln -s /usr/local/bin/node /opt/kibana/node/bin/node
sudo ln -s /usr/local/bin/npm /opt/kibana/node/bin/npm

# sudo /opt/kibana/bin/kibana

sudo cp /mnt/TimeCapsule1/raspberrypi/etc/supervisor/conf.d/* /etc/supervisor/conf.d/

# sudo /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf

sudo supervisorctl reread
sudo supervisorctl reload
