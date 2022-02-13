#!/bin/bash
source ../mylib/include.bash

PROBENAME="load-avg-5m-normalized"
PROBEVAR="avg5-std"

started

# [ https://www.kernel.org/doc/html/latest/filesystems/proc.html#kernel-data ]
loadavg=$(cat /proc/loadavg)

avg5=$(echo $loadavg | awk '{print $2}')
ncores=$(grep 'processor[[:space:]]:' /proc/cpuinfo | wc -l)

probe() {
    echo "$loadavg" | awk "{ nc=$ncores; "' printf("%.2f\n", $2/nc);}'
}

message() {
    echo "$loadavg" | awk "{ nc = $ncores; 
                             a5n = $avg5/$ncores; "' 
                             printf("(%.2f = %s/%d) %s %s %s %s (ncores: %d)\n", a5n, $2, nc, $1, $2, $3, $4, nc);
                           }'
}

# tests
probe

