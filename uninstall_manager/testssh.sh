
while true        
do

   PID=$(ssh -l root 117.78.22.13  netstat -anp | grep 9999| grep LISTEN | awk '/sshd/ && !/awk/{print $7}')
   PID=${PID%%/*}
   ssh -l root 117.78.22.13 kill -9 $PID

	 ssh -o ServerAliveInterval=60 -fCNR   9999:192.168.1.67:7778 117.78.22.13 
 
   sleep 20000s 
date 
done
