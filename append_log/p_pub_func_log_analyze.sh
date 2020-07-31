#!/bin/bash
#日志文件执行成功/失败解析
. /home/hadoop/in_data/application/shell/p_pub_func_comm.sh

function isExeSuccess()
{
vf_result=`grep -i "FAILED" -A 1 $1` >>/dev/null
if [ -z "$vf_result" ]; then
echo 1
else
echo 0
fi
}

function getRowline()
{
vf_rowline=`sed -n '/Rows loaded to/p' $1` >>/dev/null
echo `echo $vf_rowline |awk -F " " '{print $1 }'`
}

function getLastline()
{
echo `awk '{a[NR]=$0} END{print a[NR=FNR]}' $1`
}

function getFailedInfo()
{
echo `grep -i "FAILED" -A 1 $1`
}
