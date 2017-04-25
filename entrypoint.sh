#!/bin/sh

if [ $1 == "hello-world" ]
then
    if [ -z "$2" ]
    then 
        echo "No Directory Specified!"
    else
        mv ./helloOpenShift.py $2
        cd $2
        python3 helloOpenShift.py
    fi
else
    echo "Invalid command!"
fi
