#! /bin/bash

#Get memory size
totalmem=`free | awk '/Mem/{print $2;}'`
halfmem=`expr $totalmem / 2 / 1024`
halfmem=`expr \( $halfmem / 100 \) \* 100`
halfmem=${halfmem}m

#Set heapmemory
sed -i -e "s/-Xms1g/-Xms$halfmem/g" /etc/elasticsearch/jvm.options > /dev/null
sed -i -e "s/-Xmx1g/-Xmx$halfmem/g" /etc/elasticsearch/jvm.options > /dev/null