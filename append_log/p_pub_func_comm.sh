#!/bin/bash
#每一个字符是否是数字
function isDigital()
{
str=`echo $1 | sed -n "/^[0-9]\+$/p"`
if [ "x$str" == "x" ]; 
then echo 0
else echo 1
fi
}

#isDigital 300

#获取月最后一天
function getLastDay(){
year=`expr substr $1 1 4`
month=`expr substr $1 5 2`
if [ $month = '01' ] || [ $month = '03' ] || [ $month = '05' ] || [ $month = '07' ] || [ $month = '08' ] || [ $month = '10' ] || [ $month = '12' ] ; then
echo $year''$month''31
elif [ $month = '02' ] ; then
if [ `expr $year % 400` = 0 ] ; then
echo $year''$month''29
elif [ `expr $year % 4` = 0 ] && [ `expr $year % 100` != 0 ] ; then
echo $year''$month''29
else
echo $year''$month''28
fi
else
echo $year''$month''30
fi
}

##getLastDay 201310

#得到上一个月份
getLastMonth()
{
yearName=`expr substr $1 1 4`
monthName=`expr substr $1 5 2`

if [ ${monthName} -eq 1 ] ; then
yearName=`expr ${yearName} - 1`
monthName=12
else
monthName=`expr ${monthName} - 1`
monthName=`printf "%.2d" ${monthName}`
fi
echo ${yearName}${monthName}
}

##getLastMonth 201310
##getLastMonth 201301

#得到下一个月份
getNextMonth()
{
yearName=`expr substr $1 1 4`
monthName=`expr substr $1 5 2`

if [ ${monthName} -eq 12 ] ; then
yearName=`expr ${yearName} + 1`
monthName=1
monthName=`printf "%.2d" ${monthName}`
else
monthName=`expr ${monthName} + 1`
monthName=`printf "%.2d" ${monthName}`
fi
echo ${yearName}${monthName}
}


#getNextMonth 201312
#getNextMonth 201301


#月份加减
function addMonths(){
month=`expr substr $1 1 6`
day=`expr substr $1 7 2`
str=$2
num=${str#-}
t=0

if [ $2 -gt 0 ] ; then 

while [ "$t" -lt "$num" ]; do
  month=$(getNextMonth $month)
  t=`expr $t + 1`
done
echo $month$day

else

while [ "$t" -lt "$num" ]; do
  month=$(getLastMonth $month)
  t=`expr $t + 1`
done
echo $month$day
fi
}


#addMonths 201310 3
#addMonths 201302 -3
#addMonths 20130124 -5
#addMonths 20131124 5

#日期加减
function addDays(){
str=$2
num=${str#-}
if [ $2 -gt 0 ] ; then
echo `date +%Y%m%d -d "$1"+"$num"days`
else 
echo `date +%Y%m%d -d "$1"-"$num"days`
fi
}

#addDays 20131014 2 
#addDays 20131031 2
#addDays 20131001 -2
