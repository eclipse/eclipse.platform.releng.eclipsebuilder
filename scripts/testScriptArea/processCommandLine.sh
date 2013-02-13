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

# This processCommand.sh script is simply to test the 
# command line part of masterBuild.sh ... it is not used in production.

# this buildeclipse.shsource file is to ease local builds. It should not exist used for production builds.
# so we surpress the message that is does not exist.
source buildeclipse.shsource 2>/dev/null

# 0002 is often the default for shell users, but it is not when ran from
# a cron job, so we set it explicitly, so group has write access to anything
# we create.
oldumask=`umask`
umask 0002
echo "umask explicitly set to 0002, old value was $oldumask"

# set to true for test builds (controls things
# like notifications, whether or not maps are tagged, etc.
# shoudld be false for production runs.
export testbuildonly=${testbuildonly:-false}
# set to true for tesing builds, so that
# even if no changes made, build will continue.
# but during production, would be false.
export continueBuildOnNoChange=${continueBuildOnNoChange:-false}

echo "testbuildonly: $testbuildonly"
echo "continueBuildOnNoChange: $continueBuildOnNoChange"

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

# function to save a copy of full build log if we created one
function saveBuildLog()
{
    buildRoot=$1
    postingDirectory=$2
    buildId=$3
    if [[ -e "${buildRoot}/fullmasterBuildOutput.txt" ]]
    then
        buildlogsDir="${postingDirectory}/${buildId}/buildlogs"
        # it really should exist by now ... but ... in case not
        mkdir -p "${buildlogsDir}"
        # we specify -v though guess that output won't be in the log we copy :/
        # also we do no expect an existing one, but specify -b incase in
        # future there are some sort of "re-run" scenerios where it would
        # already exist, we'd want to keep all copies.
        cp -v -b "${buildRoot}/fullmasterBuildOutput.txt" "${buildlogsDir}"
    fi
}

# general purpose utility for "hard exit" is return code not zero.
# especially useful to call/check after basic things that should normally
# easily succeeed.
# usage:
#   checkForErrorExit $? "Failed to copy file (for example)"
checkForErrorExit () {
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
    if [ $exitCode -ne 0 ]
    then
        echo
        echo "   ERROR. exit code: ${exitCode}  ${message}"
        echo
        exit $exitCode
    fi
}


# get the base builder (still in cvs)
updateBaseBuilder () {

    echo "[start] [`date +%H\:%M\:%S`] updateBaseBuilder getting org.eclipse.releng.basebuilder using tag (or branch): ${basebuilderBranch}"
    echo "DEBUG: current directory as entering updateBaseBuilder ${PWD}"
    if [ -d "${supportDir}" ]
    then
        cd "${supportDir}"
        echo "   changed current directory to ${PWD}"
    else
        echo "   ERROR: support directory did not exist as expected."
        exit 1
    fi

    if [[ -z "${relengBaseBuilderDir}" ]]
    then
        echo "ERROR: relengBaseBuilderDir must be defined for this script, $0"
        exit 1
    fi
    if [[ -z "${basebuilderBranch}" ]]
    then
        echo "ERROR: basebuilderBranch must be defined for this script, $0"
        exit 1
    fi

    echo "DEBUG: relengBaseBuilderDir: $relengBaseBuilderDir"
    echo "INFO: basebuilderBranch: $basebuilderBranch"

    # scmCache has been "moved out" of base builder area,
    # and it has been improved to use origin/master to better
    # overwrite anything that it thinks should be pulled instead.
    # (creating a detached head, which is fine for scmCache).
    # but until ALL areas are known to be "unchanged"
    # safest to be sure we are clean. See bug 375794.
    if [ -e ${relengBaseBuilderDir}/eclipse.ini ]
    then
        echo "removing previous version of base builder, to be sure it is fresh. See bug 375794 "
        rm -fr ${VERBOSE_REMOVES} ${relengBaseBuilderDir}
    fi

    # existence of direcotry, is not best test of existence, since
    # sometimes the top level directory may still exist, while most files deleted,
    # due to NFS filesystem quirks. Hence, we look for specific file, the Eclipse.ini
    # file.
    if [[ ! -e "${relengBaseBuilderDir}/eclipse.ini" ]]
    then
        # make directory in case doesn't exist ${relengBaseBuilderDir}
        mkdir -p "${relengBaseBuilderDir}"
        #echo "DEBUG: creating cmd"
        # TODO: for some reason I could not get this "in" an executable command ... not enough quotes, or something?
        #cmd="cvs -d :pserver:anonymous@dev.eclipse.org:/cvsroot/eclipse ${quietCVS} ex -r ${basebuilderBranch} -d org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder"
        # cvs -d :pserver:anonymous@dev.eclipse.org:/cvsroot/eclipse ${quietCVS} ex -r ${basebuilderBranch} -d org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder
        CVSROOT=${CVSROOT:-:local:/cvsroot/eclipse}
        cvs -d ${CVSROOT} ${quietCVS} ex -r ${basebuilderBranch} -d org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder
        exitcode=$?
        #echo "cvs export cmd: ${cmd}"
        #"${cmd}"
    else
        echo "INFO: base builder already existed, so taking as accurate. Remember to delete it when fresh version needed."
        exitcode=0
    fi
    echo "DEBUG: current directory as exiting updateBaseBuilder ${PWD}"
    echo "[end] [`date +%H\:%M\:%S`] updateBaseBuilder getting org.eclipse.releng.basebuilder using tag (or branch): ${basebuilderBranch}"
    # note we save and return the return code from the cvs command itself.
    # That is so we can complete, exit, and let caller decide what to do
    # (to abort, retry, etc.)
    return $exitcode
}


updateEclipseBuilder() {

    echo "[start] [`date +%H\:%M\:%S`] updateEclipseBuilder get ${eclipsebuilder} using tag or branch: ${eclipsebuilderBranch}"
    # get fresh script. This is one case, we must get directly from repo since the purpose of the script
    # is to get the eclipsebuilder!
wget --no-verbose -O getEclipseBuilder.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/getEclipseBuilder.sh?h=${eclipsebuilderBranch} 2>&1
    chmod +x getEclipseBuilder.sh

    # execute (in current directory) ... depends on some "exported" properties.
    ./getEclipseBuilder.sh

    exitcode=$?

    echo "[end] [`date +%H\:%M\:%S`] updateEclipseBuilder get ${eclipsebuilder} using tag or branch: ${eclipsebuilderBranch}"
    return $exitcode
}


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

    mapVersionTag=${mapVersionTag:-master}
    eclipseStream=${eclipseStream:-4.2.0}
    buildType=${buildType:-N}

    # contrary to intuition (and previous behavior, bash 3.1) do NOT use quotes around right side of expression.
    if [[ "${eclipseStream}" =~ ([[:digit:]]*)\.([[:digit:]]*)\.([[:digit:]]*) ]]
    then
        eclipseStreamMajor=${BASH_REMATCH[1]}
        eclipseStreamMinor=${BASH_REMATCH[2]}
        eclipseStreamService=${BASH_REMATCH[3]}
    else
        echo "eclipseStream, $eclipseStream, must contain major, minor, and service versions, such as 4.2.0"
        exit 1
    fi
    echo "eclipseStream: $eclipseStream"
    echo "eclipseStreamMajor: $eclipseStreamMajor"
    echo "eclipseStreamMinor: $eclipseStreamMinor"
    echo "eclipseStreamService: $eclipseStreamService"


    # Normall must be supplied by caller.
    # TODO: make last segment funtion of eclipse stream and build type
    export buildRoot=${buildRoot:-/shared/eclipse/eclipse4N}

    # derived values (which effect default computed values)
    # TODO: do not recall why I export these ... should live without, if possible
    export buildDir=${buildRoot}/build
    if [[ "${testbuildonly}" == "true" ]]
    then
        export siteDir=${buildRoot}/siteDirTESTONLY
    else
    export siteDir=${buildRoot}/siteDir
    fi
    export supportDir=${buildDir}/supportDir

    # Relative constant values

    # This is eclipsebuilder name on disk, traditionally org.eclipse.releng.eclipsebuilder
    # Though now in git, the repo (and effective project name) is eclipse.platform.releng.eclipsebuilder
    # See https://bugs.eclipse.org/bugs/show_bug.cgi?id=374974 for details,
    # especially https://bugs.eclipse.org/bugs/show_bug.cgi?id=374974#c28

    export eclipsebuilder=org.eclipse.releng.eclipsebuilder
    export eclipsebuilderRepo=eclipse.platform.releng.eclipsebuilder

    relengMapsProject=${relengMapsProject:-org.eclipse.releng}
    relengRepoName=${relengRepoName:-eclipse.platform.releng.maps}

    # base builder pretty constant.
    basebuilderBranch=${basebuilderBranch:-R38M6PlusRC3G}

    # relies on export, since getEclipseBuilder is seperate script,
    # and it does not use "command line pattern"
    export eclipsebuilderBranch=${eclipsebuilderBranch:-"master"}

    # NOTE: $eclipsebuilder must be defined before builderDir
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




    # remmember "test script" area only. No need to match production scripts
    basebuilderBranch=${basebuilderBranch:-HEAD}
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
    # Changed this principle via bug 395320. For at least Kepler we'll pack/sign with Java 6.
    java14home=${java14home:-/shared/common/j2sdk1.4.2_19}
    java15home=${java15home:-/shared/common/jdk-1.5.0-22.x86_64}
    #java16home=${java16home:-/shared/common/sun-jdk1.6.0_21_x64}
    java16home=${java16home:-/shared/common/jdk1.6.0_27.x86_64}

    #still use for java15home for M builds, for now
    javaPackAndSignVMhome=${java16home}
    if [[ $buildType == "M" ]] 
    then
        javaPackAndSignVMhome=${java15home}
    fi

    pack200dir=${javaPackAndSignVMhome}/bin

    buildTimestamp=${date}-${time}
    buildTag=$buildType$buildTimestamp

    # TODO: it is confusing that buildId and buildLabel are the same
    # I think traditionally, buildId has been $date-$time and
    # buildLabel been $buildType$buildId
    # you can see this in some of the old build.property files: buildLabel=${buildType}.${buildId}
    # Note: this used to be set in the runSDKBuild function, but
    # are desired in some email messages, etc., before that runs.
    buildId=$buildType$date-$time
    buildLabel=$buildId


    postingDirectory=${siteDir}/eclipse/downloads/drops
    if [[ $eclipseStreamMajor > 3 ]]
    then
    postingDirectory=${siteDir}/eclipse/downloads/drops4
    fi
    # For 3.x builds, use "drops3" for equinox. We do not publish
    # them to downloads, but will leave on build machine
    # (for a bit) in case someone wants to "compare" them
    equinoxPostingDirectory=${siteDir}/equinox/drops3
    if [[ $eclipseStreamMajor > 3 ]]
    then
    equinoxPostingDirectory=${siteDir}/equinox/drops
    fi

    localUpdateSite=${siteDir}/updates
    buildResults=$postingDirectory/$buildTag
    submissionReportFilePath=$buildResults/report.txt

    # targetzips doesn't seem to used, even created
    # any longer? Or at the moment?
    # targets ends up producing
    # dirctories such as
    # .../eclipse4/build/targets/local-prereq-repo
    targetDir=${buildDir}/targets
    targetZips=${targetDir}/targetzips

    # should never set globally for Eclipsebuilder. That is, to java via -Dproperty=value,
    # since eclipsebuilder
    # assumes different scopes and changes this value for direct calls to generatescripts
    # TODO: I am not sure what the main one ends up being?
    #transformedRepo=${targetDir}/transformedRepo

    # should never set globally for eclipsebuilder. That is, to java via -Dproperty=value,
    # since eclipsebuilder
    # assumes different scopes and changes this value for direct calls to generatescripts
    # but in practice, the main one is
    #buildDirectory=${buildRoot}/build/supportDir/src

    relengBaseBuilderDir=$supportDir/org.eclipse.releng.basebuilder

    # is there some error conditions that would allow us to fail fast?
    return 0

}

if ${DEBUG:-false}
then
# temp: make sure what we "see" is same thing funciton sees.
echo "Reading commands from command line: $0 $* "
echo "     It contained $# arguments"
fi

processCommandLine "$@"

if ${DEBUG:-false}
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
    echo "buildId: $buildId"
    echo "buildLabel: $buildLabel"
    echo "buildResults: $buildResults"
    echo "localUpdateSite: $localUpdateSite"
    echo "equinoxPostingDirectory: $equinoxPostingDirectory"
    echo "postingDirectory: $postingDirectory"
    echo "builderDir: $builderDir"
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
# since -repack is called during sign, so we'll fail fast
if [ ! -x "${pack200dir}/pack200" ]
then
    echo "ERROR: pack200 not found, or not executable, where expected: ${pack200dir}"
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


tag=true

if ${testbuildonly:-false}
then
    tag=false
    echo "INFO: tag forced to $tag due to being a test build only"
fi

if [ "$buildType" = "N" ]; then
    tag=false
    echo "INFO: tag forced to $tag due to being an N build"
fi

if [ -f $buildRoot/${buildType}build.properties ]
then
    oldBuildTag=$( cat $buildRoot/${buildType}build.properties )
else
    oldBuildTag="NONE"
    echo "WARNING: no oldBuildTag found. Set to ${oldBuildTag}"
fi

echo "INFO: Last build: ${oldBuildTag}"




# setup - make sure reuqired directories exist


# TODO: should be able to get rid of these (eventually)
# and if needed at all, do closer to where needed
echo "supportDir: ${supportDir}"
mkdir -p "${supportDir}"
echo "buildDir: $buildDir"
mkdir -p "${buildDir}"
echo "siteDir: $siteDir"
mkdir -p "${siteDir}"
echo "gitCache: $gitCache"
mkdir -p "${gitCache}"
echo "buildResults: ${buildResults}"
mkdir -p "${buildResults}"

echo "localUpdateSite: ${localUpdateSite}"
mkdir -p "${localUpdateSite}"
echo "postingDirec: ${postingDirectory}"
mkdir -p "${postingDirectory}"
echo "equinoxPostingDirectory: ${equinoxPostingDirectory}"
mkdir -p "${equinoxPostingDirectory}"


# exit HERE if testing initial setup
# echo "testing initial setup only, exiting early"
# exit 127

# make sure exists, before we write a file there
mkdir -p $buildResults
echo "<?php " > ${buildResults}/buildProperties.php
echo "\$basebuilderBranch='${basebuilderBranch}';" >> ${buildResults}/buildProperties.php
echo "\$eclipsebuilderBranch='${eclipsebuilderBranch}';" >> $buildResults/buildProperties.php
echo "?>" >> $buildResults/buildProperties.php

updateBaseBuilder
checkForErrorExit $? "Failed while updating Base Builder"

updateEclipseBuilder
checkForErrorExit $? "Failed while updating Eclipse Builder"



tagRepo
trExitCode=$?

if [[ $trExitCode != 59 && $trExitCode != 0 ]]
then
    # check/notify of other errors, such as "push" failures
    # TODO: eventually would be an email message sent here
#    mailx -s "$eclipseStream SDK Build: $buildTag auto tagging failed. Build canceled." david_williams@us.ibm.com <<EOF
    echo "Unexpected auto-tagging return code: $trExitCode. Build halted."
    exit 1
fi

echo "trExitCode: ${trExitCode}"
echo "continueBuildOnNoChange: $continueBuildOnNoChange"

# check for "no change" code
if [[  "${trExitCode}" == "59"  ]]
then
    if [[ "${testbuildonly}" == "true" ]]
    then
        # send mail only to testonly address
        toAddress=daddavidw@gmail.com
    else
        # if not a test build, send "no change" mail to list
        #toAddress=platform-releng-dev@eclipse.org
        # can not have empty else clauses, so we'll have double test emails
        toAddress=platform-releng-dev@eclipse.org
    fi
    if [[ "${continueBuildOnNoChange}" != "true"  ]]
    then
        subjectBuildCanceled="$eclipseStream Build: $buildId canceled. No changes detected (eom)"
        (
        echo "From: e4Builder@eclipse.org"
        echo "To: ${toAddress}"
        echo "MIME-Version: 1.0"
        echo "Content-Type: text/plain; charset=utf-8"
        echo "Subject: $subjectBuildCanceled"
        echo " "
        ) | /usr/lib/sendmail -t

        echo "No changes detected by autotagging. Mail sent. $eclipseStream Build: $buildId canceled."
        exit 1

    else
        # else continue building since flag true
        subjectBuildContinue="$eclipseStream Build: $buildId started."
        (
        echo "From: e4Builder@eclipse.org"
        echo "To: ${toAddress}"
        echo "MIME-Version: 1.0"
        echo "Content-Type: text/plain; charset=utf-8"
        echo "Subject: $subjectBuildContinue"
        echo " "
        echo " No changes from previous build were detected, but "
        echo " continueBuildOnNoChange was set to true."
        echo " "
        ) | /usr/lib/sendmail -t

        echo "No changes detected by autotagging. Mail sent. $eclipseStream Build: $buildId continues."

    fi

fi

# else, to get here, we should do a build. Notification depends on test flags (and N-build)

# So, we send an email to list that a build has started and what changes were
# detected. UNLESS we are doing an N build or test build, in which case, we do not notify releng list
# Note: "continueBuildOnNoChange will sometimes be "normal" need (such if infrastructure or
# build script changes, but we've already sent that mail above.
# TODO: could use some refactoring/functions here to simply code.
if [[ "${testbuildonly}" == "true" || "${continueBuildOnNoChange}" == "true" ]]
then
    # send mail only to testonly address
    toAddress=daddavidw@gmail.com
else
    # if not a test build, and not an N-build,
    # send "build started" mail to list
    # remember, can not have empty else clauses,
    # so if desired to "comment out", must supply another
    # harmless address
    toAddress=platform-releng-dev@eclipse.org
fi
# for N builds, we do not notify anyone of "start of build" (but, do for all others? I, M? )
if [[ "${buildType}" != "N"  ]]
then

    # during test builds, won't exist, so we check for
    # existence, to avoid false warnings
    if [[ -f "$submissionReportFilePath" ]]
    then
        reporttext=$( cat $submissionReportFilePath )
    fi

    if [[ "${testbuildonly}" == "true" ]]
    then
        buildsubject="$eclipseStream TEST Build: $buildId started"
    else
        buildsubject="$eclipseStream Build: $buildId started"
    fi

    (
    echo "From: e4Builder@eclipse.org"
    echo "To: ${toAddress}"
    echo "MIME-Version: 1.0"
    echo "Content-Type: text/plain; charset=utf-8"
    echo "Subject: $buildsubject"
    echo " "
    echo "$eclipseStream Build: $buildId started"
    echo " "
    echo "   Report of changes based on comparison to"
    echo "   previous build or tag of $oldBuildTag"
    echo " "
    echo "$reporttext"
    echo " "
    ) | /usr/lib/sendmail -t

fi

# temp: remove previous "working area" due to bug ?????
# temp hard to remove completely, as sometimes NFS hangs on to some .nfs file
# TODO: find out if that's become some process is running?
# should we wait and try again? (don't seem to need to, in this case).
rm -fr ${VERBOSE_REMOVES} "${buildRoot}/build/supportDir/src"


runSDKBuild
SDKRC=$?
saveBuildLog $buildRoot $postingDirectory $buildId
checkForErrorExit $? "Failed while building Eclipse-SDK"

# Only update the IBuild.properties file if the build was successful.
# And, never for test builds. Otherwise the next build "changes" report
# will be "off", since it'd use the wrong reference point.
if [[ "${testbuildonly}" != "true" ]]
then
    echo $buildTag >$buildRoot/${buildType}build.properties
else
    echo $buildTag >$buildRoot/${buildType}-TEST-build.properties
fi

# if all ended well, put "promotion scripts" in known locations

# The 'workLocation' provides a handy central place to have the
# promote script, and log results. ASSUMING this works for all
# types of builds, etc (which is the goal for the sdk promotions).
workLocation=/shared/eclipse/sdk/promotion

# the cron job must know about and use this same
# location to look for its promotions scripts. (i.e. implicite tight coupling)
promoteScriptLocationEclipse=$workLocation/queue

# directory should normally exist -- best to create with committer's ID --
# but in case not
mkdir -p "${promoteScriptLocationEclipse}"

scriptName=promote-${eclipseStream}-${buildId}.sh
if [[ "${testbuildonly}" == "true" ]]
then
    # allows the "test" creation of promotion script, but, not have it "seen" be cron job
    scriptName=TEST-$scriptName
fi
# Here is content of promtion script:
ptimestamp=$( date +%Y%m%d%H%M )
echo "#!/usr/bin/env bash" >  ${promoteScriptLocationEclipse}/${scriptName}
echo "# promotion script created at $ptimestamp" >>  ${promoteScriptLocationEclipse}/${scriptName}
echo "$workLocation/syncDropLocation.sh $eclipseStream $buildId" >> ${promoteScriptLocationEclipse}/${scriptName}

# we restrict "others" rights for a bit more security or safety from accidents
chmod -v ug=rwx,o-rwx ${promoteScriptLocationEclipse}/${scriptName}

# no need to promote anything for 3.x builds
# (equinox portion should be the same, so we will
# create for equinox for for only 4.x primary builds)
if [[ $eclipseStream > 4 ]]
then
    # The 'workLocation' provides a handy central place to have the
    # promote script, and log results. ASSUMING this works for all
    # types of builds, etc (which is the goal for the sdk promotions).
    workLocationEquinox=/shared/eclipse/equinox/promotion

    # the cron job must know about and use this same
    # location to look for its promotions scripts. (i.e. implicite tight coupling)
    promoteScriptLocationEquinox=${workLocationEquinox}/queue

    # directory should normally exist -- best to create with committer's ID --
    # but in case not
    mkdir -p "${promoteScriptLocationEquinox}"

    eqFromDir=${equinoxPostingDirectory}/${buildId}
    eqToDir="/home/data/httpd/download.eclipse.org/equinox/drops/"

    # Note: for proper mirroring at Eclipse, we probably do not want/need to
    # maintain "times" on build machine, but let them take times at time of copying.
    # If it turns out to be important to maintain times (such as ran more than once,
    # to pick up a "more" output, such as test results, then add -t to rsync
    # Similarly, if download server is set up right, it will end up with the
    # correct permissions, but if not, we may need to set some permissions first,
    # then use -p on rsync

    # Here is content of promtion script (note, use same ptimestamp created above):
    echo "#!/usr/bin/env bash" >  ${promoteScriptLocationEquinox}/${scriptName}
    echo "# promotion script created at $ptimestamp" >  ${promoteScriptLocationEquinox}/${scriptName}
    echo "rsync --recursive \"${eqFromDir}\" \"${eqToDir}\"" >> ${promoteScriptLocationEquinox}/${scriptName}

    # we restrict "others" rights for a bit more security or safety from accidents
    chmod -v ug=rwx,o-rwx ${promoteScriptLocationEquinox}/${scriptName}
else
    echo "Did not create promote script for equinox since $eclipseStream less than 4"
fi


echo "normal exit from build phase of $0"

exit 0
