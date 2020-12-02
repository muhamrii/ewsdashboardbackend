#!/bin/bash

############################################
#COLLECT SERVER LIST EXECUTE LOG COLLECTOR #
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

my_touch $DIR/etc/server.list
/usr/bin/mysql -u root -pLast_12321 -e "use db_ewsrmsdash;select servername,ipaddress,username,password,port from tb_server" | awk 'BEGIN{OFS=";"} {print $1,$2,$3,$4,$5}' | grep -v "servername;ipaddress" >> $DIR/etc/server.list

for i in `cat $DIR/etc/server.list`
do
	SERVERNAME=`echo $i | awk -F';' '{print $1}'`
	IPADDR=`echo $i | awk -F';' '{print $2}'`
	USERNAME=`echo $i | awk -F';' '{print $3}'`
	PASSWD=`echo $i | awk -F';' '{print $4}'`
	PORT=`echo $i | awk -F';' '{print $5}'`
	$DIR/collectlog.sh $SERVERNAME $IPADDR $USERNAME $PASSWD $PORT&
done
