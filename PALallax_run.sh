#!/bin/bash

DIR=`dirname ${0}`
cd $DIR

#Get memory size
totalmem=`free | awk '/Mem/{print $2;}'`
halfmem=`expr $totalmem / 2 / 1024`


#Run PALallax
source /etc/profile.d/rvm.sh

#/usr/sbin/nginx
systemctl start nginx.service
elasticsearch-1.4.4/bin/elasticsearch -Xmx${halfmem}m -Xms${halfmem}m -d
fluentd -c config/fluentd/td-agent.conf -d fluent.pid
nohup kibana4/bin/kibana >> /dev/null &


echo 'Elasticsearch heapmemory Size:' $halfmem 'MB'