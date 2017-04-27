#!/bin/bash

set -x

export workDir="${WORKDIR:-/var/lib/chris}"

if [ -d "$workDir" ]; then
#    mkdir -p $workDir/output
    for f in $workDir/*x
    do
        if [ -f $f ]; then
            rev $f > $workDir/$(basename $f).out
        fi
    done
fi
