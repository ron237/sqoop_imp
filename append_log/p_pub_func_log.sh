#!/bin/bash
function logFile()
{
vf_procname=$1
vf_month=$2
vf_sysdate=`date '+%Y%m%d%H%M%S'`
vf_logfile=${v_execute_dir}/log/${vf_procname}_${vf_month}_${vf_sysdate}.log
touch ${vf_logfile}
echo $vf_logfile
}

function insertLog()
{
VF_CONNECT_ORA=$1
vf_month=$2
vf_pkg=$3
vf_procname=$4
vf_prov=$5
vf_tab=$6
vf_hour=$7
vf_minute=$8
vf_sysdate=`date '+%Y-%m-%d %H:%M:%S'`
echo -e "use my_dianwei_db; 
 call P_INSERT_LOG('20200930','学生基本信息','p_xsjbxx_d','2020-07-24 14:48:04','2020-07-24 14:48:04','success','60','学生基本信息sdfsadfsadfasdfasd','79.6','xsjbxx_d');" | mysql -utranswarp -pw3hK9Kidj_ -P3308 -h192.168.1.67 -s
}

function updateLog()
{
VF_CONNECT_ORA=$1
vf_month=$2
vf_pkg=$3
vf_procname=$4
vf_prov=$5
vf_retinfo=$6
vf_retcode=$7
vf_rowline=$8
vf_hour=$9
vf_minute=$10

vf_retinfo=${vf_retinfo//|/ }
vf_sysdate=`date '+%Y-%m-%d %H:%M:%S'`
echo "exec declare v1 varchar2(200); v2 varchar2(200); begin BIGDATAUSER.p_update_log_hd('$vf_month','$vf_hour','$vf_minute','$vf_pkg','$vf_procname','$vf_prov','$vf_retinfo','$vf_retcode',to_date('$vf_sysdate','yyyy-mm-dd hh24:mi:ss'),'$vf_rowline'); end;"|sqlplus -s $VF_CONNECT_ORA ;

}
