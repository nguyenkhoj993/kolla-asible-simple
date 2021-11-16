#!/bin/bash
#
# Description: Expose metrics from dmesg
#
# Author: duclh3
# example command: dmesg_log_err='dmesg -f kern --level=info'
#


log_levels=(
    emerg
    alert
    crit
    err
    warn
    notice
    info
    debug
)
facilities=(
    kern
    user
    mail
    daemon
    auth
    syslog
    lpr
    news
)
startuptime=$(cat /proc/stat | grep btime | awk '{ print $2 }')

echo '# HELP dmesg_log_number total number of logs received for a given facility and priority'
echo '# TYPE dmesg_log_number gauge'

for level in "${log_levels[@]}"; do
    for facility in "${facilities[@]}"; do
        num_log=$(dmesg -f $facility --level=$level | wc -l)
        if [ $num_log != '0' ]; then
            echo 'dmesg_log_number{facility="'$facility'",level="'$level'"} '$num_log''
        fi
    done
done


echo '# HELP dmesg_err_logs ERROR logs for facilitys.'
echo '# TYPE dmesg_err_logs gauge'

for facility in "${facilities[@]}"; do
    num_log=$(dmesg -f $facility --level=err | wc -l)
    if [ $num_log != '0' ]; then
        dmesg_command='dmesg -f '$facility' --level=err'
        while read -r line; do
            epoch_time=$(echo $line | grep -o '[0-9]*\.[0-9]*' | head -1)
            epoch_current_time=$(echo ''$epoch_time' + '$startuptime'' | bc)
            description=$(echo $line  | sed 's/\[/\[ /' | awk 'BEGIN{FS=" "}{gsub("\\\\","",$0); gsub("\"","",$0); $1=""; $2=""; print $0}' | sed 's/  //g')
            echo 'dmesg_err_logs{facility="'$facility'",description="'$description'"} '$epoch_current_time''
        done < <($dmesg_command)
    fi
done


echo '# HELP dmesg_kern_device_status kernel INFO log for device status up and down.'
echo '# TYPE dmesg_kern_device_status gauge'

while read -r line; do
    epoch_time=$(echo $line | grep -o '[0-9]*\.[0-9]*' | head -1)
    epoch_current_time=$(echo ''$epoch_time' + '$startuptime'' | bc)
    device=$(echo $line | grep -oP '([^ ]+\s\d{4}\:\d{2}:\d{2}\.\d{1}\s[^ \:]+)')
    status=$(echo $line | grep -oP '(Link is )(down|Down|up|Up).*')
    echo 'dmesg_kern_device_status{device="'$device'",status="'$status'",timestamp="'$epoch_current_time'"} '$epoch_current_time''

done < <(dmesg -l info | grep -oP ".*([^ ]+\s\d{4}\:\d{2}:\d{2}\.\d{1}\s[^ ]+).*(Link is )(down|Down|up|Up).*")

