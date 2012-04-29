#!/usr/bin/env bash

# Must have these three, rest computed

buildType=I
eclipseStream=4.2.0
mapVersionTag=R4_HEAD

# should always be 'master' for now, but in future might want
# a tag, or might need deviation between branches, temporarily). 
# (remember, if tag used, be sure to change wget commands too, they'd 
# need tag= instead of h=
initScriptTag=master

eclipseStreamMajor=${eclipseStream:0:1}

# path required when starting from cron job
export PATH=/usr/local/bin:/usr/bin:/bin:

# This file intended to be executed from cronjob
# It assumes the mbNxTx.sh file already exist in key directory, 

export buildRoot=/shared/eclipse/eclipse${eclipseStreamMajor}${buildType}

if [[ ! -d "${buildRoot}" ]] 
 then
     echo "ERROR: the expected buildRoot directory didn't exist: $buildRoot"
     exit 1
 fi
 
cd "${buildRoot}"

# TODO: need a "lock file" to prevent another job from staring if 
# one still is
date >> buildstarted.txt

wget -O "mb${eclipseStreamMajor}${buildType}.NEW.sh" "http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/mb${eclipseStreamMajor}${buildType}.sh\?h=${initScriptTag}"
rccode=$?
if [[ $rccode != 0 ]] 
then 
    echo "ERROR: wget could not fetch init script. Return code: $rccode"
    exit $rccode
fi
wget -O "masterBuild.sh" "http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/masterBuild.sh\?h=${initScriptTag}"
rccode=$?
if [[ $rccode != 0 ]] 
then 
    echo "ERROR: wget could not fetch init script. Return code: $rccode"
    exit $rccode
fi

chmod -v +x mb${eclipseStreamMajor}${buildType}.NEW.sh
rccode=$?
if [[ $rccode != 0 ]] 
then 
    echo "WARNING: could not chmod new init script. Return code: $rccode"
fi
chmod -v +x masterBuild.sh
rccode=$?
if [[ $rccode != 0 ]] 
then 
    echo "WARNING: could not chmod init script. Return code: $rccode"
fi

# debug mode, for now
DEBUG=true "${buildRoot}/masterBuild.sh" -buildType ${buildType} -eclipseStream ${eclipseStream} -buildRoot "${buildRoot}" -mapVersionTag ${mapVersionTag} 2>&1 | tee fullmasterBuildOutput.txt
