#!/bin/bash
#/*% ******************************************** 
#*名称 --%@NAME:dws_d_ev_nsl_template.sh
#*功能描述 --%@COMMENT:过程名称
#*参数 --%@PARAM:V_DATE 日期,格式YYYYMMDD
#*参数 --%@PARAM:V_RETCODE  过程运行结束成功与否标志
#*参数 --%@PARAM:V_RETINFO  过程运行结束成功与否描述
#*创建人 --%@CREATOR: huangfuhn
#*创建时间 --%@CREATED_TIME: 2017-06-19
#*主题域---%@MASTER_FIELD:
#*备注 --%@REMARK: hive_exec_main.sh dws_d_ev_nsl_template 2017010100 021
#*修改记录 --%@MODIFY: 
#*所属于实体--%@ENTITY:
#*来源表 --%@FROM: 
#*目标表 --%@TO: 
#************************************************************** %*/ 

#set -x
##函数引用
. ./p_pub_func_all.sh

##设置字符集为UTF8
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8

##***************************************************************************
#//by hfhn
#参数说明：该shell模板调用时需传入2个参数：$1为账期（yyyymmdd/yyyymmddhh/yyyymmddhhmi）$2为省份编码（021）
#例如：调用方法：hive_exec_main.sh dws_d_ev_nsl_template 2017010100 021
##***************************************************************************


##********************************************
#声明变量,变量赋值
#需修改v_owner,v_pkg,v_provname,v_tab变量的值
#执行时间（即调用时传入的时间参数）
v_exec_time=${v_exec_time}
#日期（日/月）
v_month=${v_day_id}
v_hour_id=${v_hour_id}
v_minute_id=${v_minute_id}
#省份编码（即调用时传入的第3个参数）
v_prov=${v_exec_param1}
#表名要求与shell名一致，且转换为大写
v_table_name=$(echo ${v_exec_proc} | tr '[a-z]' '[A-Z]')
v_cnt=0
v_database=gxdb
v_pkg="p_"$(echo ${v_table_name} | cut -d_ -f1-3 | tr '[A-Z]' '[a-z]')
v_procname="p_"$(echo ${v_table_name} | tr '[A-Z]' '[a-z]')
v_tab=$v_table_name
#shell名要求与表名一致，且转换为小写
v_shellname=$v_table_name | tr '[A-Z]' '[a-z]')
#记录目标表数据变化记录数
v_rowline=0
#设置oracle连接串
CONNECT_ORA=$(connOra)
#运行日志序号，一期先不考虑，后期完善
#v_log_sn=$(logSn $CONNECT_ORA)
#v_para_str="V_DATE=$v_month,V_PROV=$v_prov"
##********************************************

##***************************************************************
##日志文件定义，确定日志文件存放的位置及日志文件名称
##命名方式为：shell名称_账期_省分_系统时间戳.log
##例如：p_dwa_s_m_acc_al_charge_20170620_021_20170620172425.log
##规范：过程名统一小写
##***************************************************************
v_logfile=$(logFile $v_procname $v_exec_time $v_prov)
##判断日志文件是否存在，如果存在就清空
if [ -f $v_logfile ]
 then
   cat /dev/null > $v_logfile
fi

##************************************
#固定模板，不需修改
#插入日志
insertLog $CONNECT_ORA $v_month $v_pkg $v_procname $v_prov $v_tab $v_hour_id $v_minute_id>>/dev/null
#insertGenLog 该日志脚本保留，第一期先不实施
#insertGenLog $CONNECT_ORA $v_log_sn $v_month $v_prov $v_owner $v_procname $v_para_str $v_tab $v_hour_id $v_minute_id>>/dev/null
##************************************

##****************************************************************************
# SQL*PLUS系统变量设置
SQLSET="set long 2000000000\nset pagesize 0\nset trimout on\nset linesize 600\ncol hql_text format a1000\n"

##***********************************************
#判断前置依赖关系，需修改v_dependtable变量的值
#v_dependtable变量为定义前置依赖表的字符串，统一为大写，注意过程名要加单引号
#如果前置依赖过程为多个，过程间以逗号分隔
#例如：v_dependtable="'P_DWD_M_ACC_AL_CHARGE','P_DWD_M_ACC_AL_FEE','P_DWD_M_ACC_AL_PAYLOG'"
#注意：v_dependtable变量中禁止加空格,v_dependuser变量值统一小写
#logDepend函数的返回值为0和1: 1表示前置依赖满足，0表示前置依赖不满足
v_dependuser=bigdatauser
v_dependtable="$v_dependtable"
v_cnt=$(logDepend $CONNECT_ORA $v_month $v_prov $v_dependuser $v_dependtable $v_hour_id $v_minute_id) >>/dev/null
##***********************************************

##如果是多条件判断，使用cnt2
#v_dependuser=zc_dwa
#v_dependtable="'P_DWA_XXX'"
#v_cnt2=$(logDepend $CONNECT_ORA $v_month $v_prov $v_dependuser $v_dependtable)
##***********************************************

##***********************************************
#判断前置数据是否具备，既查看前置表是否具有数据，防止有日志，无数据的情况
#v_dependstr变量定义了前置依赖表的信息,统一为小写
#如果前置依赖的表有多个，中间以冒号分隔，结尾不需加冒号
#每个依赖表的定义格式：数据库名,表名,账期
#例如:v_dependstr="zb_dwd,dwd_m_acc_al_charge_$v_prov,$v_month:zb_dwd,dwd_m_acc_al_charge_$v_prov,$v_month"
#dataDepend函数的返回值为0和1: 1表示前置依赖满足，0表示前置依赖不满足
v_dependstr="gxdb,dws_d_ev_nsl_user_spotlint,$v_exec_time"
v_cnt3=$(dataDepend $v_dependstr $v_shellname) >>/dev/null
##***********************************************

##************************************************************
#判断前置依赖是否满足，若满足执行相关sql任务，否则状态置为等待
if [ $v_cnt -eq 1 ]; then
#if [ 1 -eq 1 ]; then

#清空分区信息
##注：表名前不能加数据库名,在执行时通过use 数据库名来锁定要清空的表
v_sql_drop=" alter table $v_table_name drop partition(month_id='"$v_month"')"
hive -e "
use $v_database;
$v_sql_drop
;" 2>&1 |tee $v_logfile >>/dev/null


#hive执行sql命令，并将执行结果写入日志文件中
hive -e "
use $v_database;
set mapred.job.priority=LOW;
set hive.groupby.skewindata=true;
set hive.exec.compress.output=true;
set mapred.output.compression.codec=org.apache.hadoop.io.compress.SnappyCodec;
set mapred.output.compression.type=BLOCK;
$v_sql
;" 2>&1 |tee $v_logfile >>/dev/null


#将执行sql信息写入明细日志中
#v_sql_t=${v_sql//\'/\"}
#insertDetLog $CONNECT_ORA $v_log_sn $v_sql_t >>/dev/null

#获取sql执行结果信息
v_result=$(isExeSuccess $v_logfile) >>/dev/null

#如果sql执行成功，执行结果状态置为SUCCESS，并从执行日志中获取执行记录数
if  [ $v_result -eq 1 ]; then
v_retcode=SUCCESS
v_retinfo=FINISH
v_rowline=$(getRowline $v_logfile) >>/dev/null

echo $v_rowline
#如果sql执行失败，执行结果状态置为FAIL，并获取执行日志中的失败信息
else
v_retcode=FAIL
v_retinfo=$(getFailedInfo $v_logfile)
v_retinfo=${v_retinfo//\'/\"}
v_retinfo=${v_retinfo// /|}
echo $v_retcode
fi

#如果不满足前置依赖关系，状态置为WAIT
else
v_retcode=WAIT
v_retinfo=WAIT
echo $v_retcode
fi
##****************************************************************

##**********************************
#更新日志
#固定模板，不需修改
updateLog $CONNECT_ORA $v_month $v_pkg $v_procname $v_prov $v_retinfo $v_retcode $v_rowline $v_hour_id $v_minute_id>>/dev/null
#updateGenLog $CONNECT_ORA $v_log_sn $v_retcode $v_retinfo >>/dev/null
##**********************************

