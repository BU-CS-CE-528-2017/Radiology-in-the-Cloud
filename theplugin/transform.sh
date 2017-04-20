#!/bin/bash

export workDir="${WORKDIR:-/var/lib/chris}"

if [ -d "$workDir" ]; then
    mkdir -p $workDir/output
    for f in $workDir/*
    do
        if [ -f $f ]; then
            rev $f > $workDir/output/$(basename $f)
        fi
    done
fi
