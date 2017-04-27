#!/bin/bash

#ReadME: to run this correctly, run: source pfurlSetup.py

echo "Setting up virtual environments..."

virtualenv pfurlEnv
virtualenv -p $(which python3) ./pfurlEnv

source ./pfurlEnv/bin/activate

echo "Setting up pfurl..."
pip3 install ./pfurl

echo "Checking for successful install..."
which pfurl
