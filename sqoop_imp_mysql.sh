#! /bin/bash
set -v
############################################
#@COMMENT: 通过sqoop抽取mysql数据
#@VERSION: 1.0
#@CREATOR: ron
#@CREATED_TIME: 2020-6-18
#@LEVEL:
#@REMARK:  sh sqoop_imp_mysql.sh static M_CITY_TEST
#@REMARK:  sh sqoop_imp_mysql.sh increm T_SCH_BBS_REPLY 20200618
#@FROM:
#@TO:
############################################

#source env
source /root/TDH-Client/init.sh
source /root/TDH-Client/sqoop_init.sh

#table type
export v_tab_type=$1
export v_tab_name=$2
export v_tab_date=$3

if [[ ${v_tab_type} == "increm" ]] ;then
    echo 'increm'
    sqoop import --connect "jdbc:mysql://192.168.1.181:3306/test_lnmec" --username root --password root \
    --target-dir /dianwei/in_data/ext/increm/${v_tab_name}/${v_tab_date} -m 1 \
    --query "select * from T_SCH_BBS_REPLY where substr(update_dt,1,8) = '20171028' and \$CONDITIONS" \
    --fields-terminated-by "," \
    --hive-drop-import-delims --null-string '\\N' --null-non-string '\\N'  --hive-overwrite --delete-target-dir
elif
   [[ ${v_tab_type} == "static" ]] ;then
    echo 'static'
    sqoop import --connect "jdbc:mysql://192.168.1.181:3306/test_lnmec" --username root --password root \
    --target-dir /dianwei/in_data/ext/M_CITY_TEST -m 1 --query "select * from m_city where \$CONDITIONS" --fields-terminated-by "," \
    --hive-drop-import-delims --null-string '\\N' --null-non-string '\\N'  --hive-overwrite --delete-target-dir 
fi

