#!/usr/bin/env bash

error(){
    echo "$1"
    exit "$2"
}

[ -z "$1" ] && error "ERROR : arg missing, please insert protocol filter" 2

prot_filter=$1
arg_length=`echo ${prot_filter} | wc -w`

# Conditional variable assignment for output file suffix, ternary operator style
suffix=$([ ${arg_length} -eq 1 ] && ${prot_filter} || echo ${prot_filter} | awk -F"==" '{print $1}' | sed 's/ *$//')

cd slice
for pcap in $(ls *); do
    # use the name of parsed files as output file prefix
    prefix=$pcap
    echo "filtering $prot_filter from $pcap"
    echo "parsed pcap will be written to ${prefix}_${suffix}.pcap"
    tshark -r $pcap -Y "$prot_filter" -w ${prefix}_${suffix}.pcap
done
