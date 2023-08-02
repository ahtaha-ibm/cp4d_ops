#!/bin/bash

KERNEL_ID=$1

[ $# -lt 1 ] && { echo "Missing Environment ID, usage: $0 KERNEL_ID" ; exit 1; }

mkdir -p ~/.tmp

#oc get pod -l icpdsupport/addOnId=spark -l kernel_id=${KERNEL_ID} > ~/.tmp/sparkmondata.tmp

oc get pod -l icpdsupport/addOnId=spark -l kernel_id=${KERNEL_ID} -o custom-columns="NAME:.metadata.name,CPU_REQUEST:.spec.containers[*].resources.requests.cpu,MEM_REQUEST:.spec.containers[*].resources.requests.memory" > ~/.tmp/sparkmondata.tmp

#cat ~/.tmp/sparkmondata.tmp

awk '
    BEGIN { idx = 0 }
    {
        print $0;
        if ( NR != 1 )
        {
            CPU[idx] = $2;
            MEM[idx] = $3;
            gsub(/[^0-9]/, "", CPU[idx]);
            gsub(/[^0-9]/, "", MEM[idx]);
            idx++
        }
    }
    END
    {
        CPUTOTAL = 0;
        MEMTOTAL = 0;
        for (count = 0; count < idx; count++)
        {
            CPUTOTAL = CPUTOTAL + CPU[count];
            MEMTOTAL = MEMTOTAL + MEM[count];
        }
        print "Total CPU Requests: " CPUTOTAL " CPUs"
        print "Total MEM Requests: " MEMTOTAL "Gi"
    }
    ' ~/.tmp/sparkmondata.tmp