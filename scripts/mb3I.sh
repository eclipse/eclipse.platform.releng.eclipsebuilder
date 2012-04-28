#!/usr/bin/env bash

# path required when starting from cron job
export PATH=/usr/local/bin:/usr/bin:/bin:

# normally will alwyas be "master" except for tests or hot fixes
export eclipsebuilderBranch=${eclipsebuilderBranch:-"master"}

# This file intended to be executed from cronjob
# It basically assumes key files already exist in key directories, 
# but the steps of getting those key files and directories are repeated here.
# This basically bootstraps the files fresh each time (after the first)
# though of course, the mbXX.sh file won't be used until the next time.

export buildRoot=/shared/eclipse/eclipse3I 
mkdir -p $buildRoot
cd $buildRoot

#TODO: need a "lock file" to prevent another job from staring if 
# one still is
date >> buildstarted.txt

wget -O mb3I.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/mb3I.sh?h=${eclipsebuilderBranch}
rccode=$?
if [[ $rccode != 0 ]] 
then 
    echo "ERROR: wget could not fetch init script. Return code: $rccode"
    exit $rccode
fi
wget -O masterBuild.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/masterBuild.sh?h=${eclipsebuilderBranch}
rccode=$?
if [[ $rccode != 0 ]] 
then 
    echo "ERROR: wget could not fetch init script. Return code: $rccode"
    exit $rccode
fi

chmod -v +x mb3I.sh
rccode=$?
if [[ $rccode != 0 ]] 
then 
    echo "WARNING: could not chmod init script. Return code: $rccode"
fi
chmod -v +x masterBuild.sh
rccode=$?
if [[ $rccode != 0 ]] 
then 
    echo "WARNING: could not chmod init script. Return code: $rccode"
fi

# production, routine version. Use 'testBuild.sh' to wrap for testing
DEBUG=true $buildRoot/masterBuild.sh -buildType I -eclipseStream 3.8.0 -buildRoot $buildRoot -mapVersionTag master 2>&1 | tee fullmasterBuildOutput.txt
