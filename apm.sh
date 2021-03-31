#!/bin/bash

#Process ID List
apmpid=$@

#Spawning processes
for i in $(seq 1 6);
do	
	#Runs every process and adds it to the apmpid list
	"./cexe/APM$i" 192.168.136.129 & temp=`echo $!`
	apmpid+=($temp)
	echo "Process ID $i: $temp"
done

#Kills processes
for i in "${apmpid[@]}";
do
	# Check if the variable is empty and continue
	if [ -z "$i" ]
	then		
		continue
	fi
	#Kill process and send any strange outputs to devnull
	kill -9 $i > /dev/null 2>&1
	echo "Proccess $i killed."
done
