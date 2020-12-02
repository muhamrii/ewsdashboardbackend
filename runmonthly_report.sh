#!/bin/bash

############################################
#   	MONTHLY REPORT COLLECTOR           #
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

my_touch $DIR/etc/server_monthly.list
/usr/bin/mysql -u root -pLast_12321 -e "use db_ewsrmsdash;select servername,ipaddress,username,password,port from tb_server" | awk 'BEGIN{OFS=";"} {print $1,$2,$3,$4,$5}' | grep -v "servername;ipaddress" >> $DIR/etc/server_monthly.list

my_touch $DIR/etc/output_parameter_monthly.list
my_touch $DIR/etc/output_parameter_disk_monthly.list
my_touch $DIR/etc/output_parameter_inodes_monthly.list
### ACTUAL THRESHOLD PARAMETER ###
/usr/bin/mysql -u root -pLast_12321 -e "use db_ewsrmsdash;select servername,ROUND(MAX(memload),2),ROUND(MIN(memload),2),ROUND(AVG(memload),2),ROUND(MAX(cpuload),2),ROUND(MIN(cpuload),2),ROUND(AVG(cpuload),2), SUM(Mem_Spike_Count) as TotalMemorySpike, SUM(CPU_Spike_Count) as TotalCPUSpike, SUM(Connection_Failed_Count) as TotalConnectionFailed, COUNT(Mem_Spike_Count) as ALLMEM, COUNT(CPU_Spike_Count) as ALLCPU, COUNT(Connection_Failed_Count) as AllConn from (select timeid, servername,memload,cpuload,sshstatus,CASE WHEN (memload) between '90.0' and '100.0' THEN 1 ELSE 0 END as Mem_Spike_Count,CASE WHEN (cpuload) between '90.0' and '100.0' THEN 1 ELSE 0 END as CPU_Spike_Count, CASE WHEN (sshstatus) = 'NOK' THEN 1 ELSE 0 END as Connection_Failed_Count from tb_cpu_ram_load where timeid BETWEEN CURDATE() - INTERVAL 30 DAY AND CURDATE()) as tb group by servername" | awk 'BEGIN{OFS=";"} {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13}' | grep -v "servername;" >> $DIR/etc/output_parameter_monthly.list

/usr/bin/mysql -u root -pLast_12321 -e "use db_ewsrmsdash;select servername,mounted,ROUND(MAX(percentageusage),2),ROUND(MIN(percentageusage),2),ROUND(AVG(percentageusage),2), SUM(Disk_Spike_Count) as TotalDiskSpike, COUNT(Disk_Spike_Count) as AllDisk from (select timeid, servername,mounted,percentageusage,CASE WHEN (percentageusage) between '90' and '100' THEN 1 ELSE 0 END as Disk_Spike_Count from tb_disk_capacity where timeid BETWEEN CURDATE() - INTERVAL 1 DAY AND CURDATE()) as tb group by servername,mounted" | awk 'BEGIN{OFS=";"} {print $1,$2,$3,$4,$5,$6,$7}' | grep -v "servername;" >> $DIR/etc/output_parameter_disk_monthly.list

/usr/bin/mysql -u root -pLast_12321 -e "use db_ewsrmsdash;select servername,mounted,ROUND(MAX(percentageiusage),2),ROUND(MIN(percentageiusage),2),ROUND(AVG(percentageiusage),2), SUM(Inodes_Spike_Count) as TotalInodesSpike, COUNT(Inodes_Spike_Count) as AllInodes from (select timeid, servername,mounted,percentageiusage,CASE WHEN (percentageiusage) between '90' and '100' THEN 1 ELSE 0 END as Inodes_Spike_Count from tb_inodes_usage where timeid BETWEEN CURDATE() - INTERVAL 30 DAY AND CURDATE()) as tb group by servername,mounted" | awk 'BEGIN{OFS=";"} {print $1,$2,$3,$4,$5,$6,$7}' | grep -v "servername;" >> $DIR/etc/output_parameter_inodes_monthly.list


for i in `cat $DIR/etc/server_monthly.list`
do
        SERVERNAME=`echo $i | awk -F';' '{print $1}'`
        IPADDR=`echo $i | awk -F';' '{print $2}'`
        USERNAME=`echo $i | awk -F';' '{print $3}'`
        PASSWD=`echo $i | awk -F';' '{print $4}'`
        PORT=`echo $i | awk -F';' '{print $5}'`
        $DIR/generatemonthlyreport.sh $SERVERNAME $IPADDR $USERNAME $PORT&
done
