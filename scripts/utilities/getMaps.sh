#!/usr/bin/env bash

# utility to get a "fresh" copy of maps to put in the working copy of 
# the maps directory. 
# is not used during normal builds or tests, but, can be 
# useful when testing changes. 
# I found a need for it when moving some stream specific 
# file files to maps, that the tests depend on, so had to 
# update the maps before testing the re-tests. 
# There is already a "utility" (that is normally used during a build)
# call getEclipseBuilder.sh for getting a fresh copy of eclipse builder, 
# this this can be used in similar way (in similar situation) where 
# things have to be udpated after the fact for testing.  

# TODO: make into variables to pass in, check, keep off of eclipseStream, etc.
supportDir=/home/shared/eclipse/eclipse4I/build/supportDir
buildDirectory="${supportDir}/src"
commonrepoDirectory="${supportDir}/src/commonrepo"
mapsVersionTag=master

# should be relatively constant
remoteMapsGitRepo=git://git.eclipse.org/gitroot/platform/eclipse.platform.releng.maps.git

mapsRepoName=eclipse.platform.releng.maps
mapsCloneDirectory="${commonrepoDirectory}/${mapsRepoName}"

mapsProjectName=org.eclipse.maps

mapDir="${buildDirectory}/maps"

# for now, for initial testing, just make the directory if 
# doesn't exist, though in practice this would be an error
if [[ ! -d "${mapDir}" ]]
then 
    echo "ERROR: expected maps direcotry did not exist"
    exit 1
    #mkdir -p "${mapDir}"
fi

# ditto
if [[ ! -d "${mapsCloneDirectory}" ]]
then 
    echo "ERROR: expected commonrepo did not exist"
    exit 1
    #git clone --branch "${mapsVersionTag}" "${remoteMapsGitRepo}"  ${mapsCloneDirectory}
    #if [[ $? != 0 ]] 
    #then
        #   echo "ERROR: could not clone as expected when testing and local repo doesn't yet exist"
        #   exit 1
    #fi
fi

# normally, what ever branch the repo is "on" is the right one, so no 
# need to "checkout" (could even be hurtful?, if we are in wrong place). 
# could to a pull/merge/rebase? But, these are files that 
# TODO: add error checking we have what we expect?
cd "${mapsCloneDirectory}"
if [[ $? != 0 ]]
then
    echo "PROGRAM ERROR: could not change to expected directory: ${mapsCloneDirectory}"
    exit 1
fi

# for the (expected) case that repo already exist, in write branch, etc., a simple 
# pull should suffice
git pull 

RC=$?

if [[ $RC != 0 ]]
then 
    echo "ERROR: pull from repo failed"
    exit 1
fi

rsync -r "${mapsCloneDirectory}/" "${mapDir}/"
RC=$?
if [[ $RC != 0 ]] 
 then
  echo "rsync from repo version to working area version failed"
  exit $RC
fi