#! /bin/bash

#Get memory size
totalmem=`free | awk '/Mem/{print $2;}'`
halfmem=`expr $totalmem / 2 / 1024`
halfmem=`expr \( $halfmem / 100 \) \* 100`
halfmem=${halfmem}m

#Set heapmemory
sed -i -e "s/#ES_HEAP_SIZE=2g/ES_HEAP_SIZE=$halfmem/g" /etc/sysconfig/elasticsearch > /dev/null

