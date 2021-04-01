#!/bin/bash

#Process ID List
pid=$@
#mem=$@
#cpu=$@
tx=$@
rx=$@


mkdir out
#Spawning processes
for i in $(seq 1 6);
do	
	#Runs every process and adds it to the apmpid list
	"./cexe/APM$i" 192.168.136.129 & temp=`echo $!`
	pid+=($temp)
	echo "Process ID $i: $temp"
	touch out/"APM$i""_metrics.csv"
done


process_metrics (){
	i=0	
	while [ $i -lt ${#pid[@]} ]
	do
		echo ${pid[$i]} 
		ps -q ${pid[$i]} -o %cpu | tail -n +2
		ps -q ${pid[$i]} -o %mem | tail -n +2
		
		((i=$i+1))
	
	done
}



#while true
#do
	process_metrics
#done


