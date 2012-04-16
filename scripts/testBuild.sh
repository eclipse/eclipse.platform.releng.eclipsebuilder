#!/usr/bin/env bash

# small utility to "wrap" a normal build script with 
# test flags set
# 

# set to true for test builds (controls things 
# like notifications, whether or not maps are tagged, etc.
# shoudld be false for production runs. 
export testbuildonly=true
# set to true for tesing builds, so that 
# even if no changes made, build will continue.
# but during production, would be false.
export continueBuildOnNoChange=true

if [ -n "${1}" ] 
then
   /bin/bash $1
else 
    echo "no script given on command line of $0"
    exit 1
fi
