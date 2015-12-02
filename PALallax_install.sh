#!/bin/bash

#root only

DIR=`dirname ${0}`
cd $DIR

##1:PALallax
yum install GeoIP GeoIP-devel wget -y

##2:Elasticsearch
yum install java -y
wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.4.4.tar.gz
tar xvzf elasticsearch-1.4.4.tar.gz
mkdir -p elasticsearch-1.4.4/data/elasticsearch/nodes/0/indices/
mkdir -p elasticsearch-1.4.4/config/templates/
cp -pf config/elasticsearch/templates/template_1.json elasticsearch-1.4.4/config/templates/
cp -prf indices/.kibana/ elasticsearch-1.4.4/data/elasticsearch/nodes/0/indices/
cp -prf indices/kibana-int/ elasticsearch-1.4.4/data/elasticsearch/nodes/0/indices/
cp -prf indices/fluentd/ elasticsearch-1.4.4/data/elasticsearch/nodes/0/indices/
\cp -pf config/elasticsearch/elasticsearch.yml elasticsearch-1.4.4/config/

##3:kibana
\cp -pf config/kibana/kibana.yml kibana4/config/

##4:Fluentd
#Install dependencies for ruby runtime
wget http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm
yum install gcc-c++ patch readline readline-devel git -y
yum install zlib zlib-devel libffi-devel -y
yum install openssl-devel make bzip2 autoconf automake libtool bison -y
yum install gdbm-devel tcl-devel tk-devel -y
yum install libxslt-devel libxml2-devel curl-devel -y
yum install --enablerepo=epel libyaml-devel -y

#RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -L https://get.rvm.io | sudo bash -s stable

#Install ruby on open another terminal

source /root/.bash_profile
source /etc/profile.d/rvm.sh

rvm install 2.0.0
rvm use 2.0.0

#ruby -v

gem install fluentd --no-doc --no-ri
ls -1R vendor/gems/ | grep -v vendor/gems/: | xargs -I{} gem install vendor/gems/{} --no-doc --no-ri

source /etc/profile.d/rvm.sh

##5:nginx
cat <<EOF> /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/x86_64/
gpgcheck=0
enabled=1
EOF

yum install --enablerepo=nginx nginx -y
cp -p /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.org
cp -p ./config/nginx/conf.d/.htpasswd /etc/nginx/conf.d/.htpasswd
\cp -pf ./config/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
yum install -y httpd-tools

##SELinux Setting
setenforce 0

\cp -pr /etc/selinux/config /etc/selinux/config.org
sed -i -e "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/selinux/config > /dev/null

#Firewall Setting

cat <<EOF> /etc/firewalld/services/snmp.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
<short>SNMP</short>
<description>SNMP protocol</description>
<port protocol="udp" port="162"/>
</service>
EOF

firewall-cmd --reload > /dev/null
firewall-cmd --permanent --zone=public --add-service=snmp > /dev/null
firewall-cmd --permanent --add-service=http > /dev/null
firewall-cmd --reload > /dev/null

#FileDescriptor Setting
ulimit -n 65535

\cp -pr /etc/security/limits.conf /etc/security/limits.conf.org
sed -i -e "/^# End of file$/i * soft nofile 65535\n* hard nofile 65535" /etc/security/limits.conf

echo "**********************"
echo "Install completed."
echo "**********************"
