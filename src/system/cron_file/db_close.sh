#! /bin/bash

DBCLOSE=`curator --host localhost close indices --older-than 62 --timestring %Y%m%d --time-unit days --prefix palo`

echo $DBCLOSE
