#!/usr/bin/env bash

# Utility to invoke p2.process.artifacts via eclipse antrunner
# First argument must be the absolute directory path to the 
# (simple) artifact repository.

source standardVariables.shsource

       repoDirLocation=$1
       if [[ -d "${repoDirLocation}" ]] 
       then
              echo "INFO: processing artifacts in code repo: $repoDirLocation";
              ${ECLIPSEBUILDER_DIR}/scripts/utilities/runAntRunner.sh process-artifacts.xml -DrepoDirLocation="${repoDirLocation}" 
              RC=$?
       else 
              echo "ERROR: the specified artifact repository directory does not exist: $repoDirLocation";
              RC=2001
       fi 
       

if [ $RC != 0 ]
  then
     echo "ERROR: pack processing did not operate as expected. Exiting the promote script early."
     exit $RC
   fi
