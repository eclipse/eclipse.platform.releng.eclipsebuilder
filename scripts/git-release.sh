#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2012 IBM Corporation and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#     IBM Corporation - initial API and implementation
#*******************************************************************************

echo "DEBUG: current directory as entering git-release.sh ${PWD}"

#default values, normally overridden by command line

writableBuildRoot=/shared/eclipse/eclipse4
relengBranch=R4_HEAD
buildType=I
# normally, timestamp is passed in on command line, and 
# date and time computed from it. 
# here we do the reverse, for when running "standalone", 
# so we can compute "now". 
date=$(date +%Y%m%d)
time=$(date +%H%M)
timestamp=$date$time
# shoud normally be passed in, but this matches what is set
# in masterBuild.sh, to aide "standalone" operation.
gitCache=$writableBuildRoot/build/supportDir/gitCache

# for safety, default is false ... must be explicit from caller to tag
# or hand-edited if runnning standalone.
tag=false

# default, but really caller should specify
# This value does not match "masterBuild.sh", but shouldn't matter.
submissionReportFilePath=$writableBuildRoot/report.txt


# constants, per project. 
# should not have to change these 
# except if/when used for another project
relengMapsProject=org.eclipse.releng
relengRepoName=eclipse.platform.releng.maps

# do not need committer id here, as long as using file:// or git://
# TODO: longterm, we'd want id and protocol specifiable
#committerId=e4Build
gitEmail=e4Build
gitName="e4Builder-R4"



ARGS="$@"

while [ $# -gt 0 ]
do
        case "$1" in
                "-relengBranch")
                        relengBranch="$2"; shift;;
                "-buildType")
                        buildType="$2"; shift;;
                "-gitCache")
                        gitCache="$2"; shift;;
                "-relengMapsProject")
                        relengMapsProject="$2"; shift;;
                "-relengRepoName")
                        relengRepoName="$2"; shift;;        
                "-root")
                        writableBuildRoot="$2"; shift;;
                "-committerId")
                        committerId="$2"; shift;;
                "-gitEmail")
                        gitEmail="$2"; shift;;
                "-gitName")
                        gitName="$2"; shift;;
                "-oldBuildTag")
                        oldBuildTag="$2"; shift;;
                "-buildTag")
                        buildTag="$2"; shift;;
                "-submissionReportFilePath")
                        submissionReportFilePath="$2"; shift;;
                 "-basebuilderBranch")
                        basebuilderBranch="$2"; shift;;
                "-eclipsebuilderBranch")
                        eclipsebuilderBranch="$2"; shift;;
                "-tag")
                        tag="$2"; shift;;
                "-timestamp")
                        timestamp="$2";
                        date=${timestamp:0:8}
                        time=${timestamp:8};
                        shift;;
                 *) break;;      # terminate while loop
        esac
        shift
done

if [ -z "$oldBuildTag"  ]; then
    # TODO: should this really be an "error exit" condidtion? 
    # or just warning? Not sure its really required? 
      # Just would not have (accurate) submission report?   
  echo "You must provide -oldBuildTag to have a submission report"
  echo "args:${ARGS}"
  exit 1
fi

if [ -z "${tag}" ]
 then
      echo "INFO: tag set to false since not specified"
      tag=false
 fi


if [ -z "$gitCache" ]; then
    echo "ERROR: must provide -gitCache location" 
	exit 1 
fi

if [ ! -d ${gitCache} ] 
then
    # gitCache should almost always already exist, so if doesn't
    # we'll create but print warning, since may indicate incorrect setting.
    echo "WARNING: gitCache location, ${gitCache}"
    echo "         did not exist, so creating it"
    mkdir -p ${gitCache}
fi

if [ -z "$buildTag" ]; then
	buildTag=$buildType${date}-${time}
fi

function checkForErrorExit ()
{
    # arg 1 must be return code, $?
    # arg 2 (remaining line) can be message to print before exiting do to non-zero exit code
    exitCode=$1
    shift
    message="$*"
    if [ -z "${exitCode}" ]
    then
        echo "PROGRAM ERROR: checkForErrorExit called with no arguments"
        exit 1
    fi
    if [ -z "${message}" ]
    then
        echo "WARNING: checkForErrorExit called without message"
        message="(Calling program provided no message)"
    fi
    if [ "${exitCode}" -ne "0" ]
    then
        echo
        echo "   ERROR. exit code: ${exitCode}"  ${message}
        echo
        exit "${exitCode}"
    fi
}



#Pull or clone a branch from a repository
#Usage: pull repositoryURL  branch
pull() {
     echo "DEBUG: pushd gitCache: ${gitCache}"
     if [ -d ${gitCache} ] 
     then 
        pushd ${gitCache}
     else
        # this is near imposible now, since we create it in this script, 
        # with a warning, if doesn't exist ... but, will leave here, in case 
        # that earlier part of script ever changes. 
        echo "could not pushd to ${gitCache} since it did not exist"
        exit 1 
     fi

 # $1 is argument to pull ... what error checking to do? 
       echo "INFO: repo: $1" 
        directory=$(basename $1 .git)
        if [ ! -d $directory ]; then
                echo repo dir did not exist yet, so git clone $1
                git clone $1
                checkForErrorExit $? "Could not clone repository $1"
                pushd ${directory}
                git config --add user.email "$gitEmail"
                git config --add user.name "$gitName"
                popd
        fi
        
        pushd $gitCache/$directory
        echo git checkout $2
        git checkout $2
        checkForErrorExit $? "Git checkout failed for repository $1 branch $2"
        echo git pull
        git pull
        checkForErrorExit $? "Git pull failed for repository $1 branch $2"
        popd
}

#Nothing to do for nightly builds, or if $noTag is specified
if [ ! $tag -o "${buildType}" = "N" ]
then
        echo "INFO: Skipping build tagging for nightly build or -tag false build"
        exit 0
fi

relengRepo="${gitCache}/${relengRepoName}"


echo "relengBranch: $relengBranch"
echo "relengRepo: $relengRepo"
# pull the releng project to get the list of repositories to tag
# since running on build.eclipse.org, under e4Build id, we can use "file://" protocol. Long term, we'd want to have variable, so could run remotely, etc.
pull "file:///gitroot/platform/${relengRepoName}.git" $relengBranch
checkForErrorExit $? "clone of repo did not succeed"

if [ ! -d "${relengRepo}" ]; then
    echo "relengRepo dir does not exist: $relengRepo" 
    exit 1
fi


# this are the "algorythm" scripts developed by Paul for e4. Should work for any repo. 
wget -O git-map.sh http://git.eclipse.org/c/e4/org.eclipse.e4.releng.git/plain/org.eclipse.e4.builder/scripts/git-map.sh
wget -O git-submission.sh http://git.eclipse.org/c/e4/org.eclipse.e4.releng.git/plain/org.eclipse.e4.builder/scripts/git-submission.sh
chmod +x git-map.sh
chmod +x git-submission.sh

rm -f repos-clean.txt clones.txt repos-report.txt

# remove comments
# TODO: remove blank lines
# convert ssh://username@git.eclipse.org/gitroot...  to file:///gitroot
repositoriesTxtPath="$relengRepo/${relengMapsProject}/tagging/repositories.txt"
echo "DEBUG: repositoriesTxtPath: $repositoriesTxtPath"
cat "$repositoriesTxtPath" | grep -v "^#" | sed 's!ssh://.*@git.eclipse.org!file://!' > repos-clean.txt


# clone or pull each repository and checkout the appropriate branch
while read line; do
        #each line is of the form <repository> <branch>
        set -- $line
        pull $1 $2
        # convert ssh://username@git.eclipse.org/gitroot...  to file:///gitroot
        # TODO: do we need to do the ssh: to file: change since done in input, repos-clean.txt?
        echo $1 | sed 's!file://!git://git.eclipse.org!' >> clones.txt
done < repos-clean.txt

cat repos-clean.txt | sed "s/ / $oldBuildTag /" >repos-report.txt

# generate the change report
echo "[git-release] git-submission.sh $gitCache $( cat repos-report.txt ) "

/bin/bash git-submission.sh $gitCache $( cat repos-report.txt ) > $submissionReportFilePath


cat clones.txt| xargs /bin/bash git-map.sh $gitCache $buildTag \
        $relengRepo > maps.txt

#Trim out lines that don't require execution
grep -v ^OK maps.txt | grep -v ^Executed >run.txt

/bin/bash run.txt

cd $relengRepo
git add $( find . -name "*.map" )
checkForErrorExit $? "Could not add maps to repository"
git commit -m "Releng build tagging for $buildTag"
# if nothing to commit, returns 1
# is this where a "merge conflict" would fail? 
# checkForErrorExit $? "Could not commit to repository"
git tag -f $buildTag   #tag the map file change
checkForErrorExit $? "Could not tag repository"


git push
checkForErrorExit $? "Could not push to repository"
git push --tags
checkForErrorExit $? "Could not push tags to repository"

popd

echo "DEBUG: current directory as exiting git-release.sh ${PWD}"
