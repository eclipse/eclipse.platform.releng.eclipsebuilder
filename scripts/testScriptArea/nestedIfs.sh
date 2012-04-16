#!/bin/bash +i

testbuildonly=true
tag=false
buildType=I

if [[ ( "${testbuildonly}" == "false" ) &&  ( "${tag}" == "false" || "${buildType}" == "N" ) ]] 
then
        echo "INFO: Skipping build tagging for nightly build or -tag false build"
        exit 0
else 
        echo "condition false"
fi
