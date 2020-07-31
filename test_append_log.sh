#!/bin/bash
export v_execute_dir=/root/shell

source ${v_execute_dir}/append_log/p_pub_func_comm.sh
source ${v_execute_dir}/append_log/p_pub_func_conn.sh
source ${v_execute_dir}/append_log/p_pub_func_log.sh
#source ${v_execute_dir}/append_log/p_pub_func_depend.sh

#connOra
#执行时间（即调用时传入的时间参数）
v_exec_time=`date '+%Y%m%d%H%M%S'`

#日期（日/月）
v_month=20200727
v_hour_id=10
v_minute_id=18

#表名要求与shell名一致，且转换为大写
v_table_name=$(echo ${v_exec_proc} | tr '[a-z]' '[A-Z]')
v_cnt=0
v_database=my_dianwei_db
v_pkg="p_"$(echo ${v_table_name} | cut -d_ -f1-3 | tr '[A-Z]' '[a-z]')
v_procname=p_xsjbxx_d
v_tab=$v_table_name
#shell名要求与表名一致，且转换为小写
#v_shellname=$v_table_name | tr '[A-Z]' '[a-z]')
#记录目标表数据变化记录数
v_rowline=0

v_logfile=$(logFile $v_procname $v_exec_time)

##判断日志文件是否存在，如果存在就清空

if [ -f $v_logfile ]
 then
   cat /dev/null > $v_logfile
fi

#插入日志
insertLog $CONNECT_ORA $v_month $v_pkg $v_procname $v_prov $v_tab $v_hour_id $v_minute_id>>/dev/null

echo -e "
what the fuck
;" 2>&1 |tee $v_logfile >>/dev/null



echo -e "
what the fuck again
;" 2>&1 |tee -a $v_logfile >>/dev/null
