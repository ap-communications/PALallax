#! /bin/bash

#Get memory size
totalmem=`free | awk '/Mem/{print $2;}'`
halfmem=`expr $totalmem / 2 / 1024`
halfmem=`expr \( $halfmem / 500 \) \* 500`


#Set heapmemory
export ES_HEAP_SIZE=$halfmem'm'
