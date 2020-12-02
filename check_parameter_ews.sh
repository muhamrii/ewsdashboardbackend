#!/bin/bash

############################################
#SCRIPT CHECKER & SUMMARY CREATOR          #
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
NOW=`date "+%F %H:%M:00"`
my_touch $DIR/SUMMARY_EWS/${SERVERNAME}.txt

###################################
######## PARAMETER COLLECT   ######
###################################

MemoryStatus=`cat $DIR/etc/output_parameter_ews.list | grep ${SERVERNAME} | awk -F';' '{print $8}'`
CPUStatus=`cat $DIR/etc/output_parameter_ews.list | grep ${SERVERNAME} | awk -F';' '{print $9}'`
Connection_Status=`cat $DIR/etc/output_parameter_ews.list | grep ${SERVERNAME} | awk -F';' '{print $10}'`
MAXCPU=`cat $DIR/etc/output_parameter_ews.list | grep ${SERVERNAME} | awk -F';' '{print $2}'`
MINCPU=`cat $DIR/etc/output_parameter_ews.list | grep ${SERVERNAME} | awk -F';' '{print $3}'`
AVGCPU=`cat $DIR/etc/output_parameter_ews.list | grep ${SERVERNAME} | awk -F';' '{print $4}'`
MAXMEM=`cat $DIR/etc/output_parameter_ews.list | grep ${SERVERNAME} | awk -F';' '{print $5}'`
MINMEM=`cat $DIR/etc/output_parameter_ews.list | grep ${SERVERNAME} | awk -F';' '{print $6}'`
AVGMEM=`cat $DIR/etc/output_parameter_ews.list | grep ${SERVERNAME} | awk -F';' '{print $7}'`
DISKCHECK=`cat $DIR/etc/output_parameter_disk_ews.list | grep ${SERVERNAME} | awk -F';' '{print $6}' | sort -u | grep "WARNING" | wc -l`

INODESCHECK=`cat $DIR/etc/output_parameter_inodes_ews.list | grep ${SERVERNAME} | awk -F';' '{print $6}' | sort -u | grep "WARNING" | wc -l`


###################################
########## SUMMARY CREATOR   ######
###################################
echo "EARLY WARNING SYSTEM ALERT" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "TIME UPDATE : ${NOW}" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "=======================" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "SERVERNAME : ${SERVERNAME}" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "IP ADDRESS : ${IPADDR}" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "USER ACCESS : ${USERNAME}" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "SSH PORT : ${PORT}" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "---------------" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "CONNECTION STATUS" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "---------------" >>  $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "${Connection_Status}" >>  $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "---------------" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "CPU USAGE" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "---------------" >>  $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "CPU STATUS : ${CPUStatus}" >>  $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "Max CPU : ${MAXCPU}%" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "Min CPU : ${MINCPU}%" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "Avg CPU : ${AVGCPU}%" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "---------------" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "MEMORY USAGE" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "---------------" >>  $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "MEMORY STATUS : ${MemoryStatus}" >>  $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "Max MEM : ${MAXMEM}%" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "Min MEM : ${MINMEM}%" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "Avg MEM : ${AVGMEM}%" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "---------------" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "DISK USAGE" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "---------------" >>  $DIR/SUMMARY_EWS/${SERVERNAME}.txt
if [[ $DISKCHECK != 0 ]]
then
  DISKSTATUS="WARNING"
  echo "DISK STATUS : ${DISKSTATUS}" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
  echo "WARNING PARTITION LIST:" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
  cat $DIR/etc/output_parameter_disk_ews.list | grep ${SERVERNAME} | grep "WARNING" | awk -F';' '{print $2" :"$5"% Used"}'  >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
else
  DISKSTATUS="NORMAL"
  echo "DISK STATUS : ${DISKSTATUS}" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
fi
echo "---------------" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "INODES USAGE" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
echo "---------------" >>  $DIR/SUMMARY_EWS/${SERVERNAME}.txt
if [[ $INODESCHECK != 0 ]]
then
  INODESSTATUS="WARNING"
  echo "INODES STATUS : ${INODESSTATUS}" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
  echo "WARNING PARTITION LIST:" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
  cat $DIR/etc/output_parameter_inodes_ews.list | grep ${SERVERNAME} | grep "WARNING" | awk -F';' '{print $2" :"$5"% Used"}' >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
else
  INODESSTATUS="NORMAL"
  echo "INODES STATUS : ${INODESSTATUS}" >> $DIR/SUMMARY_EWS/${SERVERNAME}.txt
fi

for i in `/usr/bin/mysql -u root -pLast_12321 -e "use db_ewsrmsdash;SELECT report_id,botid,groupid FROM db_report WHERE report_id = 'emergency_report'" | awk 'BEGIN{OFS=";"} {print $1,$2,$3}' | grep -v "report_id"`
do
	BOTID=`echo $i | awk -F';' '{print $2}'`
	GROUPID=`echo $i | awk -F';' '{print $3}'`
	if [ ${Connection_Status} == 'CONNECTIONPROBLEM' ] ||  [ ${CPUStatus} == 'WARNING' ] || [ ${MemoryStatus} == 'WARNING' ] || [ ${DISKSTATUS} == 'WARNING' ] || [ ${INODESCHECK} == 'WARNING' ]; then
		/usr/bin/php $DIR/phpfile/send_report_telegram.php $BOTID $GROUPID ${SERVERNAME}
	else
		echo "no warning"
	fi
done
