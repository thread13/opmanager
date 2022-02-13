#!/bin/bash
source ../mylib/include.bash

PROBENAME="load-avg-15m-normalized"
PROBEVAR="avg15-std"

started

# [ https://www.kernel.org/doc/html/latest/filesystems/proc.html#kernel-data ]
loadavg=$(cat /proc/loadavg)

avg15=$(echo $loadavg | awk '{print $3}')
ncores=$(grep 'processor[[:space:]]:' /proc/cpuinfo | wc -l)

probe() {
    echo "$loadavg" | awk "{ nc=$ncores; "' printf("%.2f\n", $3/nc);}'
}

message() {
    echo "$loadavg" | awk "{ nc = $ncores; 
                             a15n = $avg15/$ncores; "' 
                             printf("(%.2f = %s/%d) %s %s %s %s (ncores: %d)\n", a15n, $3, nc, $1, $2, $3, $4, nc);
                           }'
}

# tests
probe

