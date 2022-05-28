#! /bin/bash

#DBOPEN=`curator --host localhost open indices --older-than $# --timestring %Y%m%d --time-unit days --prefix palo`

DBOPEN=`curator open indices --index palo_syslog_log_001_$1-$2`
echo $DBOPEN

#DBSTATUS=`curl localhost:9200/_cat/indices?pretty`
#echo $DBSTATUS
