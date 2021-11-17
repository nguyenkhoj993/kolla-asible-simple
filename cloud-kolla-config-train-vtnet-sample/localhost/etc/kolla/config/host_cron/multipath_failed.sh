#!/bin/bash
#
# Script return two metrics:
# "path_failed_faulty" that had failed dm_status and faulty path_status
# "path_not_in_vm" that had not belong to any volume of VM in this compute host
# 
# Author: niemdt1 <niemdt1@viettel.com.vn> 2021
#

docker exec multipathd multipath -ll > path_ll_all.txt
echo "# path_failed_faulty"
sed -i "s/(//g" path_ll_all.txt
sed -i "s/)//g" path_ll_all.txt
all_path=`cat path_ll_all.txt | grep "dm-"`
check_dm=`echo $all_path{0} | cut -f2 -d " "`
if [[ $check_dm =~ dm-[0-9] ]]
then
    all_path=`cat path_ll_all.txt | grep "dm-" | cut -f 1 -d " "`
else
    all_path=`cat path_ll_all.txt | grep "dm-" | cut -f 2 -d " "`
fi
arr_path=($all_path)
len=`echo ${#arr_path[@]}`
for (( i=0; i<$len; i++ ))
do
    if [[ $i -eq $((len-1)) ]]
    then
        s_line=`grep -n -w ${arr_path[$i]} path_ll_all.txt | cut -f1 -d ":"`
        e_line=`wc -l path_ll_all.txt | cut -f1 -d " "`
    else
        s_line=`grep -n -w ${arr_path[$i]} path_ll_all.txt | cut -f1 -d ":"`
        e_line=`grep -n -w ${arr_path[$((i+1))]} path_ll_all.txt | cut -f1 -d ":"`
        e_line=$((e_line-1))
    fi
    sed -n "${s_line},${e_line}p" path_ll_all.txt | tail -n +3 > path_tmp.txt
    while read LINE
    do
        line=$((line+1))
        b=`echo $LINE | awk '{print $5}'`
        c=`echo $LINE | awk '{print $6}'`
        if [[ $b == 'failed' && $c == 'faulty' ]]
        then
            echo 'path_failed_faulty{path="'${arr_path[$i]}'"} 1'
            break
        fi 
    done < path_tmp.txt
done
# check path not map to vm
echo "# path_not_in_vm"
echo "" > path_tmp.txt
vms=`docker exec nova_libvirt virsh list --all | grep instance | awk '{print $2}'`
for vm in $vms
do
    docker exec nova_libvirt virsh dumpxml $vm | grep "dm-uuid-mpath" >> path_tmp.txt
done
sed -i "s/[ '/><]//g" path_tmp.txt
sed -i "s/sourcedev=devdiskby-iddm-uuid-mpath-//g" path_tmp.txt
sed -i '/^$/d' path_tmp.txt

for p_ll in $all_path
do
    result=`grep ${p_ll} path_tmp.txt`
    if [[ -z $result ]]
    then
        echo 'path_not_in_vm{path="'${p_ll}'"} 1'
    fi
done

