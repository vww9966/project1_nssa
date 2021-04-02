#!/bin/bash

# NSSA 220 PROJECT 1
#
# VAUGHN WOERPEL, MARK HOLLOWAY, RICK WALLERT

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
	networkline=$(ifstat | sed -n '/ens/s/ \+/ /gp' > /dev/null 2>&1) 
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


#Exit trap
cleanup () {
	#Kills all of the processes
	pkill -f APM > /dev/null 2>&1
	echo "Processes Killed"
}
trap cleanup EXIT

#Spawns the processes
spawn_process
#Main run portion of the file, runs once a second
v=0
#Notification about running program
echo "Program running (Ctrl + C to exit)"
while sleep 1
do
	#Runs this portion every 5 seconds for the process metrics
	if ! (($v % 5));
	then	
		process_metrics $v
	fi
	#Runs the system metrics every second	
	system_metrics $v
	((v=$v+1))
done


