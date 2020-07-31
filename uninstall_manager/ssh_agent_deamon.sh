ROMOTE_USERNAME=root
ROMOTE_SERVER_IP="117.78.22.13"
ROMOTE_PORT=9999 
###[ /sbin/ifconfig|sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p'|grep -v 127.0.0.1 ]
LOCALHOST_IP=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
LOCALHOST_IP="192.168.1.67"
LOCALHOST_PORT=7778

while true ;
do
    PID=$(ssh -l root ${ROMOTE_SERVER_IP}  netstat -anp | grep ${ROMOTE_PORT} | awk '/sshd/ && !/awk/{print $7}')
    PID=${PID%%/*}
    if [ -n "$PID" ] && [ "$PID" -gt "0" ];then
        sleep 300s
    else
        /usr/bin/ssh -l root ${ROMOTE_SERVER_IP} /bin/sh /root/kill_ssh_agent.sh ${ROMOTE_PORT}
        /usr/bin/ssh -CqTfnN -R 0.0.0.0:${ROMOTE_PORT}:${LOCALHOST_IP}:${LOCALHOST_PORT} ${ROMOTE_USERNAME}@${ROMOTE_SERVER_IP}
    fi
done

exit 0
