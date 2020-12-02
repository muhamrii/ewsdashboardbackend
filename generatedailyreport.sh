#!/bin/bash
############################################
#           DAILY SUMMARY CREATOR          #
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
PORT=$4
NOW=`date -d "1 day ago" "+%F"`
my_touch $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
###################################
######## PARAMETER COLLECT   ######
###################################
Connection_ALL=`cat $DIR/etc/output_parameter_daily.list | grep ${SERVERNAME} | awk -F';' '{print $13}'`
Connection_Failed=`cat $DIR/etc/output_parameter_daily.list | grep ${SERVERNAME} | awk -F';' '{print $10}'`
SUCCESS_RATE=`echo "scale=2; 100 * (${Connection_ALL}-${Connection_Failed}) / ${Connection_ALL}" | bc -l`
MEM_ALL=`cat $DIR/etc/output_parameter_daily.list | grep ${SERVERNAME} | awk -F';' '{print $11}'`
MEM_Failed=`cat $DIR/etc/output_parameter_daily.list | grep ${SERVERNAME} | awk -F';' '{print $8}'`
MemHealt=`echo "scale=2; 100 * (${MEM_ALL}-${MEM_Failed}) / ${MEM_ALL}" | bc -l`
CPU_ALL=`cat $DIR/etc/output_parameter_daily.list | grep ${SERVERNAME} | awk -F';' '{print $12}'`
CPU_Failed=`cat $DIR/etc/output_parameter_daily.list | grep ${SERVERNAME} | awk -F';' '{print $9}'`
CPUHealt=`echo "scale=2; 100 * (${CPU_ALL}-${CPU_Failed}) / ${CPU_ALL}" | bc -l`
MAXCPU=`cat $DIR/etc/output_parameter_daily.list | grep ${SERVERNAME} | awk -F';' '{print $2}'`
MINCPU=`cat $DIR/etc/output_parameter_daily.list | grep ${SERVERNAME} | awk -F';' '{print $3}'`
AVGCPU=`cat $DIR/etc/output_parameter_daily.list | grep ${SERVERNAME} | awk -F';' '{print $4}'`
MAXMEM=`cat $DIR/etc/output_parameter_daily.list | grep ${SERVERNAME} | awk -F';' '{print $5}'`
MINMEM=`cat $DIR/etc/output_parameter_daily.list | grep ${SERVERNAME} | awk -F';' '{print $6}'`
AVGMEM=`cat $DIR/etc/output_parameter_daily.list | grep ${SERVERNAME} | awk -F';' '{print $7}'`
###################################
########## SUMMARY CREATOR   ######
###################################
echo "DAILY REPORT MONITORING" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "DATE : ${NOW}" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "=======================" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "SERVERNAME : ${SERVERNAME}" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "IP ADDRESS : ${IPADDR}" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "USER ACCESS : ${USERNAME}" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "SSH PORT : ${PORT}" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "---------------" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "CONNECTION STATUS" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "---------------" >>  $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "SUCCESS RATE : ${SUCCESS_RATE}%" >>  $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "Connection Failed : ${Connection_Failed} Sessions" >>  $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "---------------" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "CPU USAGE" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "---------------" >>  $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "CPU HEALT(%) : ${CPUHealt}%" >>  $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "Max CPU : ${MAXCPU}%" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "Min CPU : ${MINCPU}%" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "Avg CPU : ${AVGCPU}%" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "---------------" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "MEMORY USAGE" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "---------------" >>  $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "MEMORY HEALT(%) : ${MemHealt}%" >>  $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "Max MEM : ${MAXMEM}%" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "Min MEM : ${MINMEM}%" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "Avg MEM : ${AVGMEM}%" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "---------------" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "DISK HEALT(%)" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "---------------" >>  $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
for i in `cat $DIR/etc/output_parameter_disk_daily.list | grep ${SERVERNAME}`
do
	mount=`echo $i | awk -F';' '{print $2}'`
	DISK_ALL=`echo $i | awk -F';' '{print $7}'`
	DISK_Failed=`echo $i | awk -F';' '{print $6}'`
	DISKHealt=`echo "scale=2; 100 * (${DISK_ALL}-${DISK_Failed}) / ${DISK_ALL}" | bc -l`
	echo "${mount} : ${DISKHealt}%" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
done
echo "---------------" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "INODES HEALT(%)" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
echo "---------------" >>  $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
for i in `cat $DIR/etc/output_parameter_inodes_daily.list | grep ${SERVERNAME}`
do
	mount=`echo $i | awk -F';' '{print $2}'`
	DISK_ALL=`echo $i | awk -F';' '{print $7}'`
	DISK_Failed=`echo $i | awk -F';' '{print $6}'`
	DISKHealt=`echo "scale=2; 100 * (${DISK_ALL}-${DISK_Failed}) / ${DISK_ALL}" | bc -l`
	echo "${mount} : ${DISKHealt}%" >> $DIR/SUMMARY_DAILY/${SERVERNAME}.txt
done

for i in `/usr/bin/mysql -u root -pLast_12321 -e "use db_ewsrmsdash;SELECT report_id,botid,groupid FROM db_report WHERE report_id = 'daily_report'" | awk 'BEGIN{OFS=";"} {print $1,$2,$3}' | grep -v "report_id"`
do
	BOTID=`echo $i | awk -F';' '{print $2}'`
	GROUPID=`echo $i | awk -F';' '{print $3}'`
	/usr/bin/php $DIR/phpfile/send_daily_report_telegram.php $BOTID $GROUPID ${SERVERNAME}
done
