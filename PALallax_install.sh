#! /bin/bash

echo "**********************"
echo "Install started."
echo "**********************"

echo `date`

# Version definition

elasticsearch_version="elasticsearch-7.6.0"
java_version="java-1.8.0"
curator_version="elasticsearch-curator-5.8.1"
fluentd_version="td-agent-2.5.0"
gem_elastic_version="1.18.2"
gem_polling_version="0.1.5"
gem_snmp_version="1.2.0"
gem_fluent_snmp_version="0.0.9"
kibana_version="kibana-7.6.0"
nginx_version="nginx-1.18.0"

# Preparation

echo "====Preparation===="

mkdir /var/log/PALallax
#mkdir -p /opt/PALallax/fluentd/lib
mkdir -p /var/log/elasticsearch/
#mkdir /var/lib/fluentd_buffer
mkdir -p /var/log/kibana
mkdir  /var/log/PALallax_cron

source /root/.bash_profile
cp PALallax/system/PALallax_pa_log /etc/logrotate.d/
cp PALallax/system/PALallax_cron_log /etc/logrotate.d/
cp PALallax/system/kibana_log /etc/logrotate.d/
cp PALallax/system/td-agent_log /etc/logrotate.d/
cp PALallax/system/nginx_log /etc/logrotate.d/

#cp PALallax/system/db_open.sh /opt/PALallax/
cp -R PALallax/system/cron_file /opt/PALallax/
#chmod 711 /opt/PALallax/db_open.sh
chmod -R 711 /opt/PALallax/cron_file


cp -p /etc/rsyslog.conf /etc/rsyslog.conf.`date '+%Y%m%d'`
\cp -f PALallax/system/rsyslog.conf /etc/rsyslog.conf
systemctl restart rsyslog


## Elasticsearch
echo "====Elasticsearch===="

cat <<EOF> /etc/yum.repos.d/elasticsearch.repo
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum -y install $elasticsearch_version
yum -y install $java_version


## kibana
echo "====kibana===="

cat <<EOF> /etc/yum.repos.d/kibana.repo
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum -y install $kibana_version
chown kibana:kibana /var/log/kibana

## Fluentd
echo "====Fluentd===="

#rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent

cat <<EOF> /etc/yum.repos.d/td.repo
[treasuredata]
name=TreasureData
baseurl=http://packages.treasuredata.com/2.5/redhat/\$releasever/\$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF

#yum -y install $fluentd_version
#yum -y install initscripts

## Fluentd Plugin
echo "====Fluentd Plugin===="

#/opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-elasticsearch -v $gem_elastic_version
#/opt/td-agent/embedded/bin/fluent-gem install polling  -v $gem_polling_version
#/opt/td-agent/embedded/bin/fluent-gem install snmp -v $gem_snmp_version
#/opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-snmp -v $gem_fluent_snmp_version


## curator
echo "====curator===="

cat <<EOF> /etc/yum.repos.d/curator.repo
[curator-5]
name=CentOS/RHEL 7 repository for Elasticsearch Curator 5.x packages
baseurl=https://packages.elastic.co/curator/5/centos/7
gpgcheck=1
gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
EOF

yum install -y $curator_version

## nginx
echo "====nginx===="

cat <<EOF> /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF

yum install -y $nginx_version
yum install -y httpd-tools

## Setting file copy
echo "====Setting file copy===="

### kibana
\cp -pf PALallax/kibana/config/kibana.yml /etc/kibana/kibana.yml

### Elasticsearch
echo `PALallax/elasticsearch/heapmemory_set.sh`
wait

\cp -pf PALallax/elasticsearch/config/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
chown elasticsearch:elasticsearch /etc/elasticsearch/elasticsearch.yml
chown elasticsearch:elasticsearch /var/log/elasticsearch/
chown elasticsearch:elasticsearch /var/lib/elasticsearch/

### Fluentd
#\cp -pf PALallax/fluentd/config/td-agent.conf /etc/td-agent/td-agent.conf
#\cp -pf PALallax/fluentd/lib/parser_paloalto_syslog.rb /etc/td-agent/plugin/parser_paloalto_syslog.rb
#\cp -pf PALallax/fluentd/lib/snmp_get_out_exec.rb /opt/PALallax/fluentd/lib/

sed -i -e "s/TD_AGENT_USER=td-agent/TD_AGENT_USER=root/g" /etc/init.d/td-agent
sed -i -e "s/TD_AGENT_GROUP=td-agent/TD_AGENT_GROUP=root/g" /etc/init.d/td-agent

### nginx
cp -p /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.`date '+%Y%m%d'`
cp -p /etc/nginx/nginx.conf /etc/nginx/nginx.conf.`date '+%Y%m%d'`
cp -p PALallax/nginx/config/.htpasswd /etc/nginx/conf.d/.htpasswd
\cp -pf PALallax/nginx/config/default.conf /etc/nginx/conf.d/default.conf
\cp -pf PALallax/nginx/config/nginx.conf /etc/nginx/nginx.conf


## SELinux Setting
setenforce 0

\cp -pr /etc/selinux/config /etc/selinux/config.`date '+%Y%m%d'`
sed -i -e "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/selinux/config > /dev/null

## Firewalld Setting

cat <<EOF> /etc/firewalld/services/syslog_tcp.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
<short>SYSLOG_TCP</short>
<description>SYSLOG protocol</description>
<port protocol="tcp" port="514"/>
</service>
EOF

cat <<EOF> /etc/firewalld/services/syslog_udp.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
<short>SYSLOG_UDP</short>
<description>SYSLOG protocol</description>
<port protocol="udp" port="514"/>
</service>
EOF

firewall-cmd --reload > /dev/null
firewall-cmd --permanent --zone=public --add-service=syslog_tcp > /dev/null
firewall-cmd --permanent --zone=public --add-service=syslog_udp > /dev/null
firewall-cmd --permanent --add-service=http > /dev/null
firewall-cmd --reload > /dev/null

# FileDescriptor Setting

ulimit -n 65536

\cp -pr /etc/security/limits.conf /etc/security/limits.conf.`date '+%Y%m%d'`
sed -i -e "/^# End of file$/i * soft nofile 65536\n* hard nofile 65536" /etc/security/limits.conf

# Disable yum update

echo exclude=td-agent* kibana* elasticsearch* nginx* java* >> /etc/yum.conf

# PALallax database copy
echo "====PALallax database copy===="

mkdir -p /var/lib/PALallax/backup
chown -R elasticsearch:elasticsearch /var/lib/PALallax/backup/
#cp -pr PALallax/PALallax_db/* /var/lib/PALallax/backup/

systemctl start elasticsearch.service
sleep 120s
systemctl status elasticsearch.service

curl -X PUT "localhost:9200/_snapshot/PALallax_snapshot?pretty" -H 'Content-Type: application/json' -d'                                       
{                                                                                                                                                                     
    "type": "fs",                                                                                                                                                     
    "settings": {                                                                                                                                                     
        "location": "/var/lib/PALallax/backup/",                                                                                                                      
        "compress": true                                                                                                                                              
    }                                                                                                                                                                 
}                                                                                                                                                                     
'                        

#curl -XPOST localhost:9200/_snapshot/PALallax_snapshot/snapshot_kibana/_restore

echo `PALallax/PALallax_format.sh`
wait

## Logrotate Settings




# Auto start
 echo "====Auto start===="

systemctl enable td-agent.service
systemctl enable elasticsearch.service
systemctl enable kibana.service
systemctl enable nginx.service


#systemctl start elasticsearch.service
systemctl start kibana.service
systemctl start nginx.service
systemctl start td-agent.service

systemctl status td-agent.service
systemctl status elasticsearch.service
systemctl status kibana.service
systemctl status nginx.service

date
echo "**********************"
echo "Install completed."
echo "**********************"
