#!/bin/bash
. /home/hadoop/in_data/application/shell/p_pub_func_log_analyze.sh
function logDepend(){
VF_CONNECT_ORA=$1
SQLSET="set echo off\nset head off\nset pagesize 0\nset linesize 2000\nset heading off\nset trimspool on\nset feedback off\nset term off\n"
vf_month=$2
vf_prov=$3
vf_dependuser=$4
vf_dependuser=$(echo $vf_dependuser | tr '[a-z]' '[A-Z]')
vf_dependtable=$5
vf_hour=$6
vf_minute=$7
vf_dependtable=$(echo $vf_dependtable | tr '[a-z]' '[A-Z]')
OLD_IFS="$IFS"
IFS=","
var_arr=($vf_dependtable)
IFS="$OLD_IFS"
vf_num=`echo ${#var_arr[@]}`
vf_cnt=`echo -e $SQLSET"SELECT COUNT(1) FROM ${vf_dependuser}.DW_EXECUTE_LOG_HD T WHERE T.PROCNAME IN ($vf_dependtable) AND T.PROV_ID='$vf_prov' AND T.ACCT_MONTH='$vf_month' AND T.HOUR_ID='$vf_hour' AND T.MINUTE_ID='$vf_minute' AND T.RESULT='SUCCESS' AND T.ROW_COUNT>0;"|sqlplus -s ${VF_CONNECT_ORA}`
if [ $vf_cnt -eq $vf_num ] ; then
echo 1
else
echo 0
fi
}

function dataDependPath(){
OLD_IFS="$IFS"
IFS=":"
var_arr=($1)
IFS="$OLD_IFS"
len=`echo ${#var_arr[@]}`
fix_path=/user/hive/warehouse/
depend_log=/home/mapr/zb_dwa/depend/$2.log
temp_log=/home/mapr/zb_dwa/depend/temp_$2.log
if [ -f $depend_log ]
 then
   cat /dev/null > $depend_log
fi
tot_cnt=0
inner_prov=$3

for i in ${var_arr[@]}
do
vf_db=`echo $i |awk -F "," '{print $1 }'`
vf_tabname=`echo $i |awk -F "," '{print $2 }'`
vf_date=`echo $i |awk -F "," '{print $3 }'`
date_len=`expr length $vf_date`
if [ "$vf_db"x = "zb_src"x -a $date_len -eq 8 ] ; then
inner_month=`expr substr "$vf_date" 1 6`
inner_day=`expr substr "$vf_date" 7 2`
table_path="$vf_db".db/"$vf_tabname"/prov_id="$inner_prov"/month_id="$inner_month"/day_id="$inner_day"
elif [ "$vf_db"x = "zb_src"x -a $date_len -eq 6 ] ; then
inner_month=`expr substr "$vf_date" 1 6`
table_path="$vf_db".db/"$vf_tabname"/prov_id="$inner_prov"/month_id="$inner_month"
elif [ "$vf_db"x != "zb_src"x -a $date_len -eq 8 ] ; then
inner_month=`expr substr "$vf_date" 1 6`
inner_part=`echo $((${inner_month}%2))`
inner_day=`expr substr "$vf_date" 7 2`
table_path="$vf_db".db/"$vf_tabname"/part_id="$inner_part"/day_id="$inner_day"
elif [ "$vf_db"x != "zb_src"x -a $date_len -eq 6 ] ; then
inner_month=`expr substr "$vf_date" 1 6`
table_path="$vf_db".db/"$vf_tabname"/month_id="$inner_month"
fi
hadoop fs -ls "$fix_path""$table_path" 2>&1 |tee $temp_log >> /dev/null
datafile=`grep -i "No such file or directory" -A 1 $temp_log` 
if [ -z "$datafile" ]; then
result=`sed -n '/^Found/p' $temp_log`
result=`echo $result |awk -F " " '{print $2 }'`
else
result=0
fi

if [ $result -gt 0 ] ; then 
tot_cnt=$((tot_cnt+1))
else
echo $i >> $depend_log
fi

done

if [ $tot_cnt -eq $len ] ; then 
echo 1
else 
echo 0
fi
}



function dataDependPart(){
OLD_IFS="$IFS"
IFS=":"
var_arr=($1)
IFS="$OLD_IFS"
len=`echo ${#var_arr[@]}`
vf_sysdate=`date '+%Y%m%d%H%M%S'`
depend_log=/home/mapr/zb_dwa/depend/$2_$vf_sysdate.log
if [ -f $depend_log ]
 then
   cat /dev/null > $depend_log
fi
tot_cnt=0
inner_prov=$3

for i in ${var_arr[@]}
do

vf_db=`echo $i |awk -F "," '{print $1 }'`
vf_tabname=`echo $i |awk -F "," '{print $2 }'`
vf_date=`echo $i |awk -F "," '{print $3 }'`
date_len=`expr length $vf_date`
if [ "$vf_db"x = "zb_src"x -a $date_len -eq 8 ] ; then
inner_month=`expr substr "$vf_date" 1 6`
inner_day=`expr substr "$vf_date" 7 2`
vf_sql="select * from "$vf_db"."$vf_tabname" where prov_id='"$inner_prov"' and month_id='"$inner_month"' and day_id='"$inner_day"' limit 1"
elif [ "$vf_db"x = "zb_src"x -a $date_len -eq 6 ] ; then
inner_month=`expr substr "$vf_date" 1 6`
vf_sql="select * from "$vf_db"."$vf_tabname" where prov_id='"$inner_prov"' and month_id='"$inner_month"' limit 1"
elif [ "$vf_db"x != "zb_src"x -a $date_len -eq 8 ] ; then
inner_month=`expr substr "$vf_date" 1 6`
inner_part=`echo $((${inner_month}%2))`
inner_day=`expr substr "$vf_date" 7 2`
vf_sql="select * from "$vf_db"."$vf_tabname" where part_id='"$inner_part"' and day_id='"$inner_day"' limit 1"
elif [ "$vf_db"x != "zb_src"x -a $date_len -eq 6 ] ; then
inner_month=`expr substr "$vf_date" 1 6`
vf_sql="select * from "$vf_db"."$vf_tabname" where month_id='"$inner_month"' limit 1"
fi

hive -S -e "
$vf_sql
;" 2>&1 |tee $depend_log >>/dev/null

vf_flag=$(isExeSuccess $depend_log)

if [ $vf_flag -eq 1 ]; then
vf_result=`cat $depend_log|wc -l`
else
vf_result=0
fi        
         
if [ $vf_result -eq 2 ] ; then
tot_cnt=$((tot_cnt+1))
fi

done
    
if [ $tot_cnt -eq $len ] ; then 
echo 1
else 
echo 0 
fi  
}



function dataDependData(){
OLD_IFS="$IFS"
IFS=":"
var_arr=($1)
IFS="$OLD_IFS"
len=`echo ${#var_arr[@]}`
vf_sysdate=`date '+%Y%m%d%H%M%S'`
depend_log=/home/hadoop/in_data/application/depend/$2_$vf_sysdate.log
if [ -f $depend_log ]
 then
   cat /dev/null > $depend_log
fi
tot_cnt=0
#inner_prov=$3

for i in ${var_arr[@]}
do

vf_db=`echo $i |awk -F "," '{print $1 }'`
vf_tabname=`echo $i |awk -F "," '{print $2 }'`
vf_date=`echo $i |awk -F "," '{print $3 }'`
date_len=`expr length $vf_date`
if [ "$vf_db"x = "gxdb"x -a $date_len -eq 8 ] ; then
inner_month=`expr substr "$vf_date" 1 6`
inner_day=`expr substr "$vf_date" 1 8`
vf_sql="select * from "$vf_db"."$vf_tabname" where day_id='"$inner_day"' limit 1"
elif [ "$vf_db"x = "gxdb"x -a $date_len -eq 6 ] ; then
inner_month=`expr substr "$vf_date" 1 6`
vf_sql="select * from "$vf_db"."$vf_tabname" where day_id='"$inner_month"' limit 1"
elif [ "$vf_db"x = "gxdb"x -a $date_len -eq 10 ] ; then
#inner_month=`expr substr "$vf_date" 1 6`
#inner_day=`expr substr "$vf_date" 7 2`
vf_sql="select * from "$vf_db"."$vf_tabname" where day_id='"$date_len"' limit 1"
elif [ "$vf_db"x = "gxdb"x -a $date_len -eq 12 ] ; then
inner_month=`expr substr "$vf_date" 1 6`
vf_sql="select * from "$vf_db"."$vf_tabname" where day_id='"$date_len"' limit 1"
fi

hive -S -e "
$vf_sql
;" 2>&1 |tee $depend_log >>/dev/null

vf_flag=$(isExeSuccess $depend_log)

if [ $vf_flag -eq 1 ]; then
vf_result=`cat $depend_log|wc -l`
else
vf_result=0
fi        
         
if [ $vf_result -eq 2 ] ; then
tot_cnt=$((tot_cnt+1))
fi

done
    
if [ $tot_cnt -eq $len ] ; then 
echo 1
else 
echo 0 
fi  
}



function dataDepend(){
dataDependData $1 $2
#dataDependPath $1 $2 $3
#dataDependPart $1 $2 $3
}
