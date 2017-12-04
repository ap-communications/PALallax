#! /bin/bash

DBOPEN=`curator --host localhost delete indices --older-than 367 --timestring %Y%m%d --time-unit days --prefix palo`

echo $DBOPEN
