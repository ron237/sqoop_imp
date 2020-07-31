#!/bin/sh

if [ -n "$1" ] && [ "$1" -gt "0" ];then
    PID=$(netstat -anp | grep $1 | awk '/sshd/ && !/awk/{print $7}')
    PID=${PID%%/*}

    if [ -n "${PID}" ];then
        kill -9 $PID && exit 0
    fi
fi

exit 1
