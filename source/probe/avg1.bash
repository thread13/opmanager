#!/bin/bash
source ../mylib/include.bash

PROBENAME="load-avg-1m-normalized"
PROBEVAR="avg1-std"

started

# [ https://www.kernel.org/doc/html/latest/filesystems/proc.html#kernel-data ]
loadavg=$(cat /proc/loadavg)

avg1=$(echo $loadavg | awk '{print $1}')
ncores=$(grep 'processor[[:space:]]:' /proc/cpuinfo | wc -l)

probe() {
    echo "$loadavg" | awk "{ nc=$ncores; "' printf("%.2f\n", $1/nc);}'
}

message() {
    echo "$loadavg" | awk "{ nc = $ncores; 
                             a1n = $avg1/$ncores; "' 
                             printf("(%.2f = %s/%d) %s %s %s %s (ncores: %d)\n", a1n, $1, nc, $1, $2, $3, $4, nc);
                           }'
}

# tests
probe

