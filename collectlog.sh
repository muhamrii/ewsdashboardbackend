#!/bin/bash

############################################
#LOG COLLECTOR & DATA PROCESSOR            #
#Created By : Muhammad Amri                #
############################################

my_touch() {
    if test -f $1
    then
        rm -f $1
        touch $1
    else
        touch $1
    fi
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SERVERNAME=$1
IPADDR=$2
USERNAME=$3
PASSWD=$4
PORT=$5
NOW=`date "+%FT%H:%M:00"`
my_touch $DIR/log/${SERVERNAME}.log

###########################################
########## RUN LOG COLLECTOR ##############
###########################################

/usr/bin/expect $DIR/collector.exp $IPADDR $USERNAME $PASSWD $PORT >> $DIR/log/${SERVERNAME}.log

###########################################
############## PARSE LOG ##################
###########################################

######## MEM LOAD & CPULOAD #######
MEMLOAD=`cat $DIR/log/${SERVERNAME}.log | grep "MemLoad:" | egrep -v "free|awk" | awk '{print $NF}' | sed 's/%//g' | tr -d '\r'`
CPULOAD=`cat $DIR/log/${SERVERNAME}.log  | grep "Cpu" | grep -v top | awk '{print $2}' | sed 's/%us,//g'`

if [ -z "${MEMLOAD}" ] && [ -z "${CPULOAD}" ]
then
      PING="NOK"
      MEMLOAD="0.0"
      CPULOAD="0.0"
else
      PING="OK"
fi

my_touch $DIR/importdb/${SERVERNAME}_load.csv
echo "${NOW},${SERVERNAME},${MEMLOAD},${CPULOAD},${PING}" >> $DIR/importdb/${SERVERNAME}_load.csv

######## DISK USAGE & INODES USAGE #######
cd $DIR/log/
/usr/bin/perl $DIR/parserlog.pl ${SERVERNAME}.log $DIR $NOW

my_touch $DIR/importdb/${SERVERNAME}_diskusage.csv
cat $DIR/importdb/${SERVERNAME}_diskusage.tmp | egrep -v "df|exit|Filesystem|Cpu" | sed 's/,$//g;s/%//g' >> $DIR/importdb/${SERVERNAME}_diskusage.csv
rm $DIR/importdb/${SERVERNAME}_diskusage.tmp

my_touch $DIR/importdb/${SERVERNAME}_inodesusage.csv
cat $DIR/importdb/${SERVERNAME}_inodesusage.tmp | egrep -v "df|exit|Filesystem" | sed 's/,$//g;s/%//g;s/,-,/,0,/g' >> $DIR/importdb/${SERVERNAME}_inodesusage.csv
rm $DIR/importdb/${SERVERNAME}_inodesusage.tmp


###########################################
######## IMPORT DATA TO DB ################
###########################################

function import {
/usr/bin/mysql -u root -pLast_12321 << EOF
use db_ewsrmsdash
LOAD DATA INFILE '$1' REPLACE INTO TABLE $2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';
EOF
}

cp $DIR/importdb/${SERVERNAME}_load.csv /var/lib/mysql-files/.
cp $DIR/importdb/${SERVERNAME}_diskusage.csv /var/lib/mysql-files/.
cp $DIR/importdb/${SERVERNAME}_inodesusage.csv /var/lib/mysql-files/.
import /var/lib/mysql-files/${SERVERNAME}_load.csv tb_cpu_ram_load
import /var/lib/mysql-files/${SERVERNAME}_diskusage.csv tb_disk_capacity
import /var/lib/mysql-files/${SERVERNAME}_inodesusage.csv tb_inodes_usage
