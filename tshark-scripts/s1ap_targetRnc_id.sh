#!/usr/bin/env bash

FILE="./DNS_NoCache_20170323_Merged_v2_Parsed_rnc.pcap"

for frame in `cat dnsframe.txt`
do
    echo "Parsing raw pcap file for frame number ${frame}"
    tshark -r $FILE -Y "frame.number == ${frame}" -w DNS_NoCache_20170323_Merged_v2_Parsed_rnc_${frame}.pcap
done
