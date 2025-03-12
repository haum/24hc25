#!/usr/bin/bash

OPT_IPG=$(ip a | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){2}[0-9]*).*/\2.0\/24/p')
OPT_FILTER="haumbot"

while getopts hf:g: opt; do case $opt in
	f)
		OPT_FILTER="$OPTARG"
	;;
	g)
		OPT_IPG="$OPTARG"
	;;
	h|?)
		echo "Usage: $0 [-h] [-g addr/n] [grep_pattern]"
		echo "Find network neighbors and resolve their mdns hostname"
		echo "-f pattern    A grep filter to apply to output ($OPT_FILTER)"
		echo "-g addr/n     Group to search ($OPT_IPG)"
		echo "-h            This help"
		exit
	;;
esac; done
shift $(($OPTIND - 1))

for ip in $(fping -Aqag -r1 -i1 $OPT_IPG)
do
	if [[ -z "$OPT_FILTER" ]]
	then
		avahi-resolve-address $ip || echo $ip &
	else
		avahi-resolve-address $ip | grep -e $OPT_FILTER &
	fi
done

for job in `jobs -p`; do wait $job; done
