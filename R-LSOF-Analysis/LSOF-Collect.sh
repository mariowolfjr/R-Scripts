#!/bin/bash

date="`date +%G"-"%m"-"%d"_"%H-%M`"

# Write status TCP and UDP ports -----
netstat -ano | grep "10.175.21.160" | wc | sed "s|^|$date  |g" >> monitor_tcp_21.160.txt
ss -nutlp | grep "11:8" | wc  | sed "s|^|$date  |g" >> monitor_udp_rtp.txt

# Check number of files opened by process
lsof > .temp.txt
awk 'NR>1{arr[$1]++}END{for (a in arr) print a, arr[a]}' .temp.txt > .temp2.txt

# Add Date time in front of each line
sed "s|^|$date  |g" .temp2.txt > lsof_$date.txt


