#!/bin/sh

if [ $1 == "hello-world" ]
then 
    python3 helloOpenShift.py
else
    echo "Invalid command!"
fi
