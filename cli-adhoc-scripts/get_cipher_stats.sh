#!/usr/bin/env bash

# cipher_stat.sh
# Created on 2016-09-29
# Author = __gandhi__ (ngakan.gandhi@packet-systems.com)
# Version 1.0

# Declare Environment
PATH='/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin'
source $HOME/.bash_profile

# Declare Vars
DATENOW=`date +%Y-%m-%d-%H`
USER="psi.gandhi"
PASSWORD="Gandhisgsn06!"
VSGBTR05_IP="10.205.57.4"
VSGCBT04_IP="10.205.62.4"
VSGCBT05_IP="10.205.67.4"
RAWFILE_LOG="/home/backup/temp/sgsnmme-cipherstat.tmp"

# Declare KPI Directories
VSGBTR05_KPIDIR="/home/backup/kpi/2016/VSGBTR05"
VSGCBT04_KPIDIR="/home/backup/kpi/2016/VSGCBT04"
VSGCBT05_KPIDIR="/home/backup/kpi/2016/VSGCBT05"

# Logs VSGBTR05 Cipher Table
/usr/bin/expect << EOF
spawn /usr/bin/ssh ${USER}@${VSGBTR05_IP}
log_file -a ${RAWFILE_LOG}
expect {
    "yes/no" { send "yes\r" ; exp_continue }
    "password:" { send "${PASSWORD}\r" ; exp_continue }
}
expect "#"
send "show mme-service session full all | grep 128-eea\r"
expect -timeout 420
expect "#"
send "exit\r"
EOF

# Logs VSGCBT04 Cipher Table
/usr/bin/expect << EOF
spawn /usr/bin/ssh ${USER}@${VSGCBT04_IP}
log_file -a ${RAWFILE_LOG}
expect {
    "yes/no" { send "yes\r" ; exp_continue }
    "password:" { send "${PASSWORD}\r" ; exp_continue }
}
expect "#"
send "show mme-service session full all | grep 128-eea\r"
expect -timeout 420
expect "#"
send "exit\r"
EOF

# Logs VSGCBT05 Cipher Table
/usr/bin/expect << EOF
spawn /usr/bin/ssh ${USER}@${VSGCBT05_IP}
log_file -a ${RAWFILE_LOG}
expect {
    "yes/no" { send "yes\r" ; exp_continue }
    "password:" { send "${PASSWORD}\r" ; exp_continue }
}
expect "#"
send "show mme-service session full all | grep 128-eea\r"
expect -timeout 420
expect "#"
send "exit\r"
EOF

# Convert raw log to Unix format (replacement for missing dos2unix util)
/usr/bin/perl -pi -e 's/\r\n/\n/' $RAWFILE_LOG

# Print stats to log
# Check for current date, counted from midnight, since epoch
curtime=$(date -d "`date | awk '{print $1" "$2" "$3" "$6 }'`" +%s)

# Declare log file and directories
touch /home/backup/kpi/2016/CIPHER/sgsnmme-cipher-stats-$curtime.csv
SGSNMME_CIPHER_LOG_DAILY="/home/backup/kpi/2016/CIPHER/sgsnmme-cipher-stats-$curtime.csv"

# Append header to first line only if it does not exist in the first place
grep -vq -F 'TIMESTAMP;VSGBTR05_eea0;VSGBTR05_eea1;VSGBTR05_eea2;VSGCBT04_eea0;VSGCBT04_eea1;VSGCBT04_eea2;VSGCBT05_eea0;VSGCBT05_eea1;VSGCBT05_eea2' $SGSNMME_CIPHER_LOG_DAILY || echo "TIMESTAMP;VSGBTR05_eea0;VSGBTR05_eea1;VSGBTR05_eea2;VSGCBT04_eea0;VSGCBT04_eea1;VSGCBT04_eea2;VSGCBT05_eea0;VSGCBT05_eea1;VSGCBT05_eea2" >> $SGSNMME_CIPHER_LOG_DAILY

# Check for rawfile existence
if [ -f "$RAWFILE_LOG" ]; then
    # set timestamp
    TIMESTAMP=`date +"%Y-%m-%d_%H:%M:%S"`

    ## Parse Rawlog
    # VSGBTR05

    VSGBTR05_eea0=`sed -n '/VSGBTR05#/,/VSGBTR05#/p' $RAWFILE_LOG | grep "128-eea0" | wc -l`
    VSGBTR05_eea1=`sed -n '/VSGBTR05#/,/VSGBTR05#/p' $RAWFILE_LOG | grep "128-eea1" | wc -l`
    VSGBTR05_eea2=`sed -n '/VSGBTR05#/,/VSGBTR05#/p' $RAWFILE_LOG | grep "128-eea2" | wc -l`

    # VSGCBT04
    VSGCBT04_eea0=`sed -n '/VSGCBT04#/,/VSGCBT04#/p' $RAWFILE_LOG | grep "128-eea0" | wc -l`
    VSGCBT04_eea1=`sed -n '/VSGCBT04#/,/VSGCBT04#/p' $RAWFILE_LOG | grep "128-eea1" | wc -l`
    VSGCBT04_eea2=`sed -n '/VSGCBT04#/,/VSGCBT04#/p' $RAWFILE_LOG | grep "128-eea2" | wc -l`

    # VSGCBT05
    VSGCBT05_eea0=`sed -n '/VSGCBT05#/,/VSGCBT05#/p' $RAWFILE_LOG | grep "128-eea0" | wc -l`
    VSGCBT05_eea1=`sed -n '/VSGCBT05#/,/VSGCBT05#/p' $RAWFILE_LOG | grep "128-eea1" | wc -l`
    VSGCBT05_eea2=`sed -n '/VSGCBT05#/,/VSGCBT05#/p' $RAWFILE_LOG | grep "128-eea2" | wc -l`

	echo "$TIMESTAMP;$VSGBTR05_eea0;$VSGBTR05_eea1;$VSGBTR05_eea2;$VSGCBT04_eea0;$VSGCBT04_eea1;$VSGCBT04_eea2;$VSGCBT05_eea0;$VSGCBT05_eea1;$VSGCBT05_eea2" >> $SGSNMME_CIPHER_LOG_DAILY

    # Delete rawfile
    rm -rf $RAWFILE_LOG
else
    echo "$RAWFILE_LOG not found" >> /home/backup/syslog.log
fi

# Empty nohup.out
cat /dev/null > /home/Automation/nohup.out
