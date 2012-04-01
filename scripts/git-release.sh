#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2011 IBM Corporation and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#     IBM Corporation - initial API and implementation
#*******************************************************************************

#default values, overridden by command line
oldBuildTag="I20120321-0610"
writableBuildRoot=/shared/eclipse/e4/dwtest/eclipse4

relengMapsProject=org.eclipse.releng
relengRepoName=eclipse.platform.releng.maps

relengBranch=R4_HEAD
buildType=I
date=$(date +%Y%m%d)
time=$(date +%H%M)
timestamp=$date$time
# do not need committer id here, as long as using file:// or git://
# TODO: longterm, we'd want id and protocol specifiable
#committerId=e4Build
gitEmail=e4Build
gitName="e4Builder-R4"
# default is false ... must be explicit to tag
tag=false
# default, but let caller specify
submissionReportFilePath=$writableBuildRoot/$buildTag/report.txt

ARGS="$@"

while [ $# -gt 0 ]
do
        case "$1" in
                "-branch")
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
  echo You must provide -oldBuildTag
  echo args: "$ARGS"
  exit
fi

if ! $tag; then
	noTag=true
fi

supportDir=$writableBuildRoot/supportDir
if [ -z "$gitCache" ]; then
	gitCache=$supportDir/gitClones
fi

if [ -z "$buildTag" ]; then
	buildTag=$buildType${date}-${time}
fi

#Pull or clone a branch from a repository
#Usage: pull repositoryURL  branch
pull() {
     if [ -d "${gitCache}" ] 
	then 
           pushd $gitCache
	else
	   echo "could not pushd to $gitCache since it did not exist"
       exit 1 
    fi

 # $1 is argument to pull ... what error checking to do?  
        directory=$(basename $1 .git)
        if [ ! -d $directory ]; then
                echo git clone $1
                git clone $1
                cd $directory
                git config --add user.email "$gitEmail"
                git config --add user.name "$gitName"
        fi
        popd
        pushd $gitCache/$directory
        echo git checkout $2
        git checkout $2
        echo git pull
        git pull
        popd
}

#Nothing to do for nightly builds, or if $noTag is specified
if $noTag || [ "$buildType" == "N" ]; then
        echo Skipping build tagging for nightly build or -tag false build
        exit
fi

pushd $writableBuildRoot
relengRepo=$gitCache/${relengRepoName}


# pull the releng project to get the list of repositories to tag
# since running on build.eclipse.org, under e4Build id, we can use "file://" protocol. Long term, we'd want to have variable, so could run remotely, etc.
#pull "ssh://$committerId@git.eclipse.org/gitroot/e4/org.eclipse.e4.releng.git" $relengBranch
echo "relengBranch: $relengBranch"
echo "relengRepo: $relengRepo"

pull "file:///gitroot/platform/${relengRepoName}.git" $relengBranch

if [ ! -d $relengRepo ]; then
    echo "relengRepo dir does not exist: $relengRepo" 
    exit 1
fi


# this are the "algorythm" scripts developed by Paul for e4. Should work for any repo. 
wget -O git-map.sh http://git.eclipse.org/c/e4/org.eclipse.e4.releng.git/plain/org.eclipse.e4.builder/scripts/git-map.sh
wget -O git-submission.sh http://git.eclipse.org/c/e4/org.eclipse.e4.releng.git/plain/org.eclipse.e4.builder/scripts/git-submission.sh

rm -f repos-clean.txt clones.txt repos-report.txt

# remove comments
# TODO: remove blank lines
# convert ssh://username@git.eclipse.org/gitroot...  to file:///gitroot
repositoriesTxtPath="$relengRepo/${relengMapsProject}/tagging/repositories.txt"
echo "repositoriesTxtPath: $repositoriesTxtPath"
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
mkdir $writableBuildRoot/$buildTag
echo "[git-release]" git-submission.sh $gitCache $( cat repos-report.txt )
/bin/bash git-submission.sh $gitCache $( cat repos-report.txt ) > $submissionReportFilePath


cat clones.txt| xargs /bin/bash git-map.sh $gitCache $buildTag \
        $relengRepo > maps.txt

#Trim out lines that don't require execution
grep -v ^OK maps.txt | grep -v ^Executed >run.txt

#temp exit
exit

/bin/bash run.txt

#temp exit
exit

cd $relengRepo
git add $( find . -name "*.map" )
git commit -m "Releng build tagging for $buildTag"
git tag -f $buildTag   #tag the map file change

git push
git push --tags

popd
