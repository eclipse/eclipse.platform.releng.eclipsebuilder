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


# set to true for tesing builds, even if no changes made
# but during production, would normally be false.
export continueBuildOnNoChange=true
# set to true for test builds (controls other things like notifications, etc.)
export testbuildonly=true

# settings related to debugging or testing
# DEBUG controls verbosity of little "state and status" bash echo messages.
# Set to true to get the most echo messages. Anything else to be quiet. 
# Normally would be false during production, but true for debugging/tests. 
export DEBUG=${DEBUG:-false}
#export DEBUG=${DEBUG:-true}
echo "DEBUG: $DEBUG"

# VERBOSE_REMOVES needs to be empty or literally '-v', since
# simply makes up part of "rm" command when directories or files removed.
# normally empty for production runs, but might help in debugging.
# (but, it is VERY verbose)
export VERBOSE_REMOVES=${VERBOSE_REMOVES:-}
#export VERBOSE_REMOVES=${VERBOSE_REMOVES:--v}
echo "VERBOSE_REMOVES: $VERBOSE_REMOVES"

# quietCVS needs to be -Q (really quiet) -q (somewhat quiet) or literally empty (verbose)
# FYI, not that much difference between -Q and -q :) 
# TODO: won't be needed once move off CVS is complete
export quietCVS=${quietCVS:--Q}
#export quietCVS=${quietCVS:--q}
#export quietCVS=${quietCVS:-" "}
echo "quiteCVS: $quietCVS"


processCommandLine ()
{
    #
    #  control various aspects of the build via command line arguments
    #

    echo "Reading commands from command line: $0 $* " 
    echo "     It contained $# arguments"

    while [ $# -gt 0 ]
    do
        case "$1" in
            "-mapVersionTag")
                mapVersionTag="$2"; shift;;
            "-eclipseStream")
                eclipseStream="$2"; shift;;
            "-buildType")
                buildType="$2"; shift;;
            "-gitCache")
                gitCache="$2"; shift;;
            "-relengMapsProject")
                relengMapsProject="$2"; shift;;
            "-relengRepoName")
                relengRepoName="$2"; shift;;  
            "-buildRoot")
                buildRoot="$2"; shift;;
            "-gitEmail")
                gitEmail="$2"; shift;;
            "-gitName")
                gitName="$2"; shift;;
            "-basebuilderBranch")
                basebuilderBranch="$2"; shift;;
            "-eclipsebuilderBranch")
                eclipsebuilderBranch="$2"; shift;;
            "-timestamp")
                timestamp="$2";
                date=${timestamp:0:8}
                time=${timestamp:8};
                shift;;
            *) break;;      # terminate while loop
        esac
        shift
    done

    if $DEBUG 
    then
        echo  
        echo  
        echo  
        echo "DEBUG raw values after reading command line"
        echo "DEBUG: mapVersionTag: ${mapVersionTag}"
        echo "DEBUG: eclipseStream: ${eclipseStream}"
        echo "DEBUG: buildType: ${buildType}"
        echo "DEBUG: gitCache: ${gitCache}"
        echo "DEBUG: relengMapsProject: ${relengMapsProject}"
        echo "DEBUG: relengRepoName: ${relengRepoName}"
        echo "DEBUG: buildRoot ${buildRoot}"
        echo "DEBUG: gitEmail: ${gitEmail}"
        echo "DEBUG: gitName: ${gitName}"
        echo "DEBUG: basebuilderBranch: ${basebuilderBranch}"
        echo "DEBUG: eclipsebuilderBranch: ${eclipsebuilderBranch}"
        echo "DEBUG: timestamp: ${timestamp}"
        echo "DEBUG: date: ${date}"
        echo "DEBUG: time: ${time}"
        echo  
        echo  
        echo  
    fi


    # if any commnad line parameter is not set yet,
    # either by above loop, or an environment variable, then
    # specify a reasonable default.

    mapVersionTag=${mapVersionTag:-R4_HEAD}
    eclipseStream=${eclipseStream:-4.2}
    buildType=${buildType:-N}

    relengMapsProject=${relengMapsProject:-org.eclipse.releng}
    relengRepoName=${relengRepoName:-eclipse.platform.releng.maps}

    # TODO: make last segment "projectName" 
    buildRoot=${buildRoot:-/shared/eclipse/eclipse4N}

    # derived values (which effect default computed values) 
    # TODO: do not recall why I export these ... should live without, if possible
    export buildDir=${buildRoot}/build
    export siteDir=${buildRoot}/siteDir

    export supportDir=${buildDir}/supportDir

    export builderDir=${supportDir}/$eclipsebuilder
    # remember: do not "mkdir" for builderDir since presence/absence 
    # might be used later to determine if fresh check out needed or not.
    # mkdir -p "${builderDir}"


    if [ -z "$gitCache" ]; then
        export gitCache=${supportDir}/gitCache
    else
        echo "WARNING: non-derived value of gitCache already defined: ${gitCache}"
    fi

    export gitEmail=${gitEMail:-e4Build}
    export gitName=${gitName:-e4Builder-R4}


    # Relative constant values

    # This is eclipsebuilder name on disk, traditionally org.eclipse.releng.eclipsebuilder
    # Though now in git, the repo (and effective project name) is eclipse.platform.releng.eclipsebuilder 
    # See https://bugs.eclipse.org/bugs/show_bug.cgi?id=374974 for details, 
    # especially https://bugs.eclipse.org/bugs/show_bug.cgi?id=374974#c28
    export eclipsebuilder=org.eclipse.releng.eclipsebuilder
    export eclipsebuilderRepo=eclipse.platform.releng.eclipsebuilder

    basebuilderBranch=${basebuilderBranch:-R4_2_primary}
    # relies on export, since getEclipseBuilder is seperate script, 
    # and it does not use "command line pattern"
    export eclipsebuilderBranch=${eclipsebuilderBranch:-"master"}

    # if timestamp not set, compute it from "now"
    date=${date:-$(date +%Y%m%d)}
    time=${time:-$(date +%H%M)}
    timestamp=${timestamp:-$date$time}



    # common properties that would vary machine to machine
    # Would have to run under Java 1.5, to make sure 'sign' (which uses jar processor) 
    # and eventual "pack200" can all be unpacked with 1.5. 
    # long term, we can launch those tasks in seperate process, or some other better way.
    java15home=/shared/common/jdk-1.5.0-22.x86_64
    #java15home=/shared/orbit/apps/ibm-java2-i386-50/jre
    java16home=/shared/common/sun-jdk1.6.0_21_x64
    pack200dir=${java15home}/bin

    buildTimestamp=${date}-${time}
    buildTag=$buildType$buildTimestamp


    postingDirectory=${siteDir}/eclipse/downloads/drops4
    equinoxPostingDirectory=${siteDir}/equinox/drops
    localUpdateSite=${siteDir}/updates
    buildResults=$postingDirectory/$buildTag
    submissionReportFilePath=$buildResults/report.txt


    # these don't seem right (not sure what they are)?
    # currently ends up being 
    # .../eclipse4/build/targets
    # and contains the ?local repo? (not runnable) for org.eclipse.emf.common, etc.
    # in directories named, for example,
    # as .../eclipse4/build/targets/local-repo-I20120331-0050
    targetDir=${buildDir}/targets
    targetZips=${targetDir}/targetzips

    # should not set globally to java via -Dproperty=value, since eclipsebuilder 
    # assumes different scopes and changes this value for direct calls to generatescripts
    #transformedRepo=${targetDir}/transformedRepo

    # should not set globally to java via -Dproperty=value, since eclipsebuilder 
    # assumes different scopes and changes this value for direct calls to generatescripts
    # but in practice, the main one is
    #buildDirectory=${buildRoot}/build/supportDir/src

    #rembember, don't point to e4Build user directory
    sdkTestDir=${buildRoot}/sdkTests/$buildTag

    sdkResults=$buildDir/$buildTag/$buildTag
    sdkBuildDirectory=$buildDir/$buildTag

    relengBaseBuilderDir=$supportDir/org.eclipse.releng.basebuilder



}

if $DEBUG 
then
# temp: make sure what we "see" is same thing funciton sees.
echo "Reading commands from command line: $0 $* " 
echo "     It contained $# arguments"
fi 

processCommandLine "$@"

if $DEBUG 
then
    echo " "
    echo " "
    echo " "
    echo "DEBUG  Command line values after reading command line and initializing"
    echo "DEBUG: mapVersionTag ${mapVersionTag}"
    echo "DEBUG: eclipseStream ${eclipseStream}"
    echo "DEBUG: buildType ${buildType}"
    echo "DEBUG: gitCache ${gitCache}"
    echo "DEBUG: relengMapsProject ${relengMapsProject}"
    echo "DEBUG: relengRepoName ${relengRepoName}"
    echo "DEBUG: buildRoot ${buildRoot}"
    echo "DEBUG: gitEmail ${gitEmail}"
    echo "DEBUG: gitName ${gitName}"
    echo "DEBUG: basebuilderBranch ${basebuilderBranch}"
    echo "DEBUG: eclipsebuilderBranch ${eclipsebuilderBranch}"
    echo "DEBUG: timestamp ${timestamp}"
    echo "DEBUG: date: ${date}"
    echo "DEBUG: time: ${time}"
    echo " "
    echo " "
    echo " "
    echo
    echo "DEBUG: other interesting settings: " 
    echo "buildResults: $buildResults"
    echo "localUpdateSite: $localUpdateSite"
    echo "equinoxPostingDirectory: $equinoxPostingDirectory"
    echo "postingDirectory: $postingDirectory"
fi 

# be sure to exit HERE if just testing command line, 
# before any work gets done. 
#echo "testing params. exit before doing work"
#exit 127


# for safety, for now, we'll assume if this directory does not already exist, something is wrong, 
# since, currently, we should be running "under" it. 
#mkdir -p "${buildRoot}"
if [  ! -d $buildRoot ]
then
    echo "ERROR: the top level buildRoot must already exist. exiting build."
    echo "buildRoot: $buildRoot" 
    exit 128
fi

# if pack200 doesn't exist where expected it can cause condidtioning to not work as epxected, 
# since -repack is called during sign
if [ ! -x "${pack200dir}/pack200" ]
then
    echo "ERROR: pack200 not found (or, not executable) where expected: ${pack200dir}"
    exit 1
fi

export JAVA_HOME=${java16home} 
echo "INFO: JAVA_HOME ${JAVA_HOME}"
if [  ! -d ${JAVA_HOME} ]
then
    echo "ERROR: JAVA_HOME does not exist, so is probably defined incorrectly."
    echo "JAVA_HOME: $JAVA_HOME" 
    exit 128
fi



# used in auto-tagging
# normally set true here, for production, but then 
# a nightly build would set it to false
# set to false for test builds
tag=true

if [ "$buildType" = "N" ]; then
    echo "INFO: tag forced to false due to being an N build"
    tag=false
fi

if [ -f $buildRoot/${buildType}build.properties ]
then
    oldBuildTag=$( cat $buildRoot/${buildType}build.properties )
else
    echo "WARNING: no oldBuildTag found. Set to NONE"
    oldBuildTag="NONE"
fi
echo "Last build: $oldBuildTag"
echo $buildTag >$buildRoot/${buildType}build.properties





# setup - make sure reuqired directories exist 


# TODO: should be able to get rid of these (eventually) and if needed at all, do closer to where needed
mkdir -p "${supportDir}"
mkdir -p $gitCache
mkdir -p $buildResults
mkdir -p $localUpdateSite 
mkdir -p $postingDirec
mkdir -p $equinoxPostingDirectory
mkdir -p "${buildDir}"
echo "buildDir: $buildDir"
mkdir -p "${siteDir}"
echo "siteDir: $siteDir"





# temp hard to remove up from, using linux, as ant sometimes fail 
# to remove .nsf files
rm -fr "${buildRoot}/build/supportDir/src"

updateBaseBuilder
checkForErrorExit $? "Failed while updating Base Buidler"

updateEclipseBuilder
checkForErrorExit $? "Failed while updating Eclipse Buidler"

tagRepo
#trExitCode=$?

#if [ "${trExitCode}" != "99999" ]
#then
#   checkForErrorExit ${trExitCode} "Failed during auto tagging"
#fi

#echo "trExitCode: ${trExitCode}"
#echo "continueBuildOnNoChange: $continueBuildOnNoChange"

#if [ ( "${trExitCode}" = "99999" ) && ( "${continueBuildOnNoChange}" != "true" ) ]
#then 
#    mailx -s "$eclipseStream SDK Build: $buildTag auto tagging failed. Build canceled." david_williams@us.ibm.com <<EOF

#  Auto tagging failed. See log. 
#Build halted.

#EOF
#   exit 99999
#fi

# else, to get here, we've had zero return codes or continueBuildOnNoChange is true

runSDKBuild
checkForErrorExit $? "Failed while building Eclipse-SDK"

