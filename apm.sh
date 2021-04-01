#!/bin/bash

#Process ID List
pid=$@

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
	i=1
	while [ $i -lt ${#pid[@]} ]
	do
		temppid=${pid[$i]} 
		echo "$temppid"
		temp1=$(ps -q $temppid -o %cpu | tail -n +2)
		temp2=$(ps -q $temppid -o %mem | tail -n +2)
		echo "$temp1,$temp2" >> out/"APM$i""_metrics.csv"
		((i=$i+1))
	done
}

while true
do
	process_metrics
done

pkill -f APM

