#!/bin/bash
my_ping(){
ping -c2 -i0.2 -W1 $1 &>/dev/null
   if [ $? -eq 0 ];then
	echo "$1 is up" >> up.txt
   else
	echo "$1 is down">>down.txt
   fi
}
for i in `seq 254`
do
   my_ping 192.168.1.$i &
done
wait
