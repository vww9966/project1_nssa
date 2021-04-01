#!/bin/bash

#Process ID List
pid=$@

#Makes a directory to put the csv files into
mkdir out > /dev/null 2>&1

#Spawning processes
spawn_process () {
	for i in $(seq 1 6);
	do	
		#Runs every process and adds it to the pid list
		"./cexe/APM$i" 192.168.136.129 & temp=`echo $!`
		pid+=($temp)
		#echo "Process ID $i: $temp"
		#Creates the file for the APM metrics CSV
		touch out/"APM$i""_metrics.csv"
	done
}

#Gathers the individual process metrics and then writes to the csv file
process_metrics (){
	i=1
	#Loops through all of the processes
	while [ $i -lt ${#pid[@]} ]
	do
		temppid=${pid[$i]}
		#Gathers % CPU use
		cpu=$(ps -q $temppid -o %cpu | tail -n +2)
		#Gathers % Memory use
		mem=$(ps -q $temppid -o %mem | tail -n +2)
		#Writes to the file
		echo "$1,$cpu,$mem" >> out/"APM$i""_metrics.csv"
		((i=$i+1))
	done
}

#Gathers overall system metrics and writes to the csv file
system_metrics (){
	#Gets network usage statistics and formats it
	networkline=$(ifstat | sed -n '/ens/s/ \+/ /gp')
	#Formats rx and tx network usage from the overall usage statistics
	rx=$(echo $networkline | cut -d " " -f 6)
	tx=$(echo $networkline | cut -d " " -f 8)
	#Gathers hard drive write data and formats it
	hdwrite=$(iostat | sed -n '/sda/s/ \+/ /gp' | cut -d " " -f 4)
	#Gathers free hard drive space and formats it
	hdutil=$(df | sed -n '/sda3/s/ \+/ /gp' | cut -d " " -f 4)
	((hdutil=$hdutil/1000))	
	#Writes all statistics to a csv file
	echo "$1,$rx,$tx,$hdwrite,$hdutil" >> "out/system_metrics.csv"
}

#Spawns the processes
spawn_process
#Main run portion of the file, runs once a second
v=0
while sleep 1
do
	echo $v
	#echo $(($v%5))
	#Runs this portion every 5 seconds for the process metrics
	if ! (($v % 5));
	then	
		process_metrics $v
	fi
	#Runs the system metrics every second	
	system_metrics $v
	((v=$v+1))
done

pkill -f APM

