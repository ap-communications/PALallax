#! /bin/bash

echo "**********************"
echo "Install started."
echo "**********************"

echo `date`

# Version definition

elasticsearch_version="8.1.1"
java_version="java-1.8.0"
gem_elastic_version="7.16.3"
gem_fluent_elastic_version="5.1.4"


# Preparation

echo "====Preparation===="

read -rp 'Setting time zone: ' TIME_ZONE

install -m 755 -o syslog -g adm -d /var/log/APC
mkdir -p /opt/APC/fluentd/lib
mkdir -p /opt/APC/elasticsearch
mkdir /var/lib/fluentd_buffer
mkdir -p /var/log/kibana

cp src/system/forti_log /etc/logrotate.d/
cp src/system/palo_log /etc/logrotate.d/
cp src/system/nozomi_log /etc/logrotate.d/
cp src/system/kibana_log /etc/logrotate.d/
cp src/system/td-agent_log /etc/logrotate.d/
cp src/system/nginx_log /etc/logrotate.d/


cp -p /etc/rsyslog.conf /etc/rsyslog.conf.`date '+%Y%m%d'`
\cp -f /etc/rsyslog.d/50-default.conf /etc/rsyslog.d/50-default.conf.`date '+%Y%m%d'`
\cp -f src/system/rsyslog.conf /etc/rsyslog.conf
\cp -f src/system/50-default.conf /etc/rsyslog.d/50-default.conf
systemctl restart rsyslog


## Elasticsearch
echo "====Elasticsearch===="

sudo apt-get install -y apt-transport-https
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update && sudo apt-get install -y elasticsearch=$elasticsearch_version


## kibana
echo "====kibana===="
curl -O "https://apc-kibana-repo.s3.ap-northeast-1.amazonaws.com/pkg-palallax/palallax-kibana-8.1.1-SNAPSHOT-amd64.deb"
curl -O "https://apc-kibana-repo.s3.ap-northeast-1.amazonaws.com/pkg-palallax/palallax-kibana-8.1.1-SNAPSHOT-amd64.deb.sha1.txt"
echo `sha1sum palallax-kibana-8.1.1-SNAPSHOT-amd64.deb`
echo `cat palallax-kibana-8.1.1-SNAPSHOT-amd64.deb.sha1.txt`
sudo dpkg -i palallax-kibana-8.1.1-SNAPSHOT-amd64.deb

## Fluentd
echo "====Fluentd===="

ulimit -n 1048576
curl -fsSL https://toolbelt.treasuredata.com/sh/install-debian-bullseye-td-agent4.sh | sh

## Fluentd Plugin
echo "====Fluentd Plugin===="

td-agent-gem install elasticsearch -v $gem_elastic_version
td-agent-gem install fluent-plugin-elasticsearch -v $gem_fluent_elastic_version
 
## Setting file copy
echo "====Setting file copy===="

### kibana
cp -pf src/kibana/config/kibana.yml /etc/kibana/kibana.yml
mkdir /etc/kibana/certs

cp /usr/share/kibana/src/core/server/core_app/assets/favicons/favicon.png /usr/share/kibana/src/core/server/core_app/assets/favicons/favicon.png`date '+%Y%m%d'`
cp /usr/share/kibana/src/core/server/core_app/assets/favicons/favicon.svg /usr/share/kibana/src/core/server/core_app/assets/favicons/favicon.svg`date '+%Y%m%d'`
cp -pf src/kibana/favicon.png /usr/share/kibana/src/core/server/core_app/assets/favicons/favicon.png
cp -pf src/kibana/favicon.svg /usr/share/kibana/src/core/server/core_app/assets/favicons/favicon.svg

cp -p /usr/share/kibana/src/core/server/rendering/views/logo.js /usr/share/kibana/src/core/server/rendering/views/logo.js`date '+%Y%m%d'`
cp -p /usr/share/kibana/src/core/server/rendering/views/template.js /usr/share/kibana/src/core/server/rendering/views/template.js`date '+%Y%m%d'`
cp -pf src/kibana/logo.js /usr/share/kibana/src/core/server/rendering/views/logo.js
cp -pf src/kibana/template.js /usr/share/kibana/src/core/server/rendering/views/template.js

### Elasticsearch
echo `src/elasticsearch/jvmoptions_set.sh`
wait

cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.`date '+%Y%m%d'`
cp -pf src/elasticsearch/config/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
chown elasticsearch:elasticsearch /etc/elasticsearch/elasticsearch.yml
chown elasticsearch:elasticsearch /var/log/elasticsearch/
chown elasticsearch:elasticsearch /var/lib/elasticsearch/

### Fluentd
\cp -pf src/fluentd/config/td-agent.conf /etc/td-agent/td-agent.conf
\cp -pf src/fluentd/lib/parser_fortigate_syslog.rb /etc/td-agent/plugin/parser_fortigate_syslog.rb
\cp -pf src/fluentd/lib/parser_paloalto_syslog.rb /etc/td-agent/plugin/parser_paloalto_syslog.rb
\cp -pf src/fluentd/lib/parser_nozomi_syslog.rb /etc/td-agent/plugin/parser_nozomi_syslog.rb

install -m 640 -o syslog -g adm /dev/null /var/log/APC/forti.log
install -m 640 -o syslog -g adm /dev/null /var/log/APC/palo.log
install -m 640 -o syslog -g adm /dev/null /var/log/APC/nozomi.log

sed -i -e "s/User=td-agent/User=root/g" /lib/systemd/system/td-agent.service
sed -i -e "s/Group=td-agent/Group=root/g" /lib/systemd/system/td-agent.service

sed -i -e "s/time_zone 0/time_zone $TIME_ZONE/g" /etc/td-agent/td-agent.conf


## ufw check
echo `sudo ufw status`


# FileDescriptor Setting
# Default setting for Ubuntu Focal is 1048576
echo `ulimit -n`


# Disable yum update
sed -i -e "s/"1"/"0"/g" /etc/apt/apt.conf.d/20auto-upgrades

# database copy
echo "====database copy===="

mkdir -p /var/lib/APC/backup
chown -R elasticsearch:elasticsearch /var/lib/APC/backup/

# Auto start
 echo "====Auto start===="

systemctl enable td-agent.service
systemctl enable elasticsearch.service
systemctl enable kibana.service

date
echo "**********************"
echo "Install completed."
echo "**********************"
