#!/bin/bash


# 
# Maintainer: trangtth22 & donghm
# Description: Expose metrics for HBA port's state and speed
#

echo "#Display status port HBA"
echo "#Online=1"
echo "#Offline=0"

fc_path="/sys/class/fc_host/"

hosts="$(ls $fc_path)"

for host in $hosts; do
    state="$(cat $fc_path/$host/port_state)"
    name="$(cat $fc_path/$host/port_name)"
    speed="$(cat $fc_path/$host/speed | awk '{print$1}')"
    fabric_name="$(cat $fc_path/$host/fabric_name)"

    if [ $speed == 'unknown' ]; then
        echo 'hba_port_speed{host="'$host'", name="'$name'", fabric_name="'$fabric_name'"} 0'
    else
        echo 'hba_port_speed{host="'$host'", name="'$name'", fabric_name="'$fabric_name'"} '$speed''
    fi


    if [ $state != 'Online' ]; then
       	echo 'hba_port_state{host="'$host'", name="'$name'", fabric_name="'$fabric_name'"} 0'
    else
        echo 'hba_port_state{host="'$host'", name="'$name'", fabric_name="'$fabric_name'"} 1'
    fi
done

