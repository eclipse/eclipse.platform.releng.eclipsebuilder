#!/usr/bin/env bash

# Must have these three, rest computed

buildType=N
eclipseStream=4.3.0
mapVersionTag=master

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

wget --no-verbose -O "mb${eclipseStreamMajor}${buildType}.NEW.sh" "http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/mb${eclipseStreamMajor}${buildType}.sh?h=${initScriptTag}"
rccode=$?
if [[ $rccode != 0 ]] 
then 
    echo "ERROR: wget could not fetch init script. Return code: $rccode"
    exit $rccode
fi
wget --no-verbose -O "masterBuild.sh" "http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/masterBuild.sh?h=${initScriptTag}" 2>&1
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

# if no difference bewteen old and new, remove "new" else, print warning
differs=`diff mb${eclipseStreamMajor}${buildType}.NEW.sh mb${eclipseStreamMajor}${buildType}.sh`
echo "differs: ${differs}"
if [ -z "${differs}" ]
then 
    # 'new' not different from existing, so remove 'new' one
    rm mb${eclipseStreamMajor}${buildType}.NEW.sh
else
    echo " " 
    echo "     wgetSDKPromoteScripts.sh has changed. Compare with and consider replacing with mb${eclipseStreamMajor}${buildType}.NEW.sh"
    echo "  "
fi

chmod -v +x masterBuild.sh
rccode=$?
if [[ $rccode != 0 ]] 
then 
    echo "WARNING: could not chmod init script. Return code: $rccode"
fi

# debug mode, for now
DEBUG=true "${buildRoot}/masterBuild.sh" -buildType ${buildType} -eclipseStream ${eclipseStream} -buildRoot "${buildRoot}" -mapVersionTag ${mapVersionTag} 2>&1 | tee fullmasterBuildOutput.txt
