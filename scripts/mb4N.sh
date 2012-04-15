#!/usr/bin/env bash

# This file intended to be executed from cronjob
# It basically assumes key files already exist in key directories, 
# but the steps of getting those key files and directories are repeated here.
# This basically bootstraps the files fresh each time (after the first)
# though of course, the mb4NCaptureOutput.sh won't be used until the next time.

# path required when starting from cron job
export PATH=/usr/local/bin:/usr/bin:/bin:

buildRoot=/shared/eclipse/eclipse4N 
mkdir -p $buildRoot
cd $buildRoot

date >> job4nstarted.txt

wget -O mb4N.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/mb4N.sh?h=master;
wget -O masterBuild.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/masterBuild.sh?h=master;

chmod -c +x *.sh

# Debug version
DEBUG=true $buildRoot/masterBuild.sh -buildType N -eclipseStream 4.2 -buildRoot $buildRoot -mapVersionTag R4_HEAD 2>&1 | tee fullmasterBuildOutput.txt

# production, routine version
#$buildRoot/masterBuild.sh -buildType N -eclipseStream 4.2 -buildRoot $buildRoot -mapVersionTag R4_HEAD
