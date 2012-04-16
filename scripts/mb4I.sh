#!/usr/bin/env bash

# This file intended to be executed from cronjob
# It basically assumes key files already exist in key directories, 
# but the steps of getting those key files and directories are repeated here.
# This basically bootstraps the files fresh each time (after the first)
# though of course, the mb4I.sh won't be used until the next time.
buildRoot=/shared/eclipse/eclipse4I 
mkdir -p $buildRoot
cd $buildRoot
wget -O mb4I.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/mb4I.sh?h=master;
wget -O masterBuild.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/masterBuild.sh?h=master;

chmod -v +x mb4I.sh
chmod -v +x masterBuild.sh

# Debug version
DEBUG=true $buildRoot/masterBuild.sh -buildType I -eclipseStream 4.2 -buildRoot $buildRoot -mapVersionTag R4_HEAD  2>&1 | tee fullmasterBuildOutput.txt

# production, routine version
#$buildRoot/masterBuild.sh -buildType I -eclipseStream 4.2 -buildRoot $buildRoot -mapVersionTag R4_HEAD
