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
    if [ "${exitCode}" -ne "0" ]
    then
        echo
        echo "   ERROR. exit code: ${exitCode}"  ${message}
        echo
        exit "${exitCode}"
    fi
}


# get the base builder (still in cvs)
updateBaseBuilder () {

    echo "[start] [`date +%H\:%M\:%S`] getting org.eclipse.releng.basebuilder using tag (or branch): ${basebuilderBranch}"
    echo "DEBUG: current directory as entering updateBaseBuilder ${PWD}"
    if [ -d "${supportDir}" ]
    then
        cd "${supportDir}"
        echo "   changed current directory to ${PWD}"
    else
        echo "   ERROR: support directory did not exist as expected."  
        exit 1
    fi 
    
    echo "DEBUG: relengBaseBuilderDir: $relengBaseBuilderDir"
    
    if [ -d ${relengBaseBuilderDir} ]
     then
           echo "removing previous version of base builder, to be sure it is fresh, to see if related to to see if fixes bug 375780"
           rm -fr ${VERBOSE_REMOVES} ${relengBaseBuilderDir}
     fi
     
    # TODO existence or not may not be good test. Sometimes the top level directory may exist, 
    # but didn't get cleanup up entirely due to NFS file system quirks.
    # for now, we'll always get ... then find better "key file" under it to check for
    #if [[ ! -d "${relengBaseBuilderDir}" ]] 
    #then
        #    echo "making directory: ${relengBaseBuilderDir}"
        #mkdir -p "${relengBaseBuilderDir}"
        #echo "DEBUG: creating cmd"
        # TODO: for some reason I could not get this "in" an executable command ... not enough quotes, or something? 
        #cmd="cvs -d :pserver:anonymous@dev.eclipse.org:/cvsroot/eclipse ${quietCVS} ex -r ${basebuilderBranch} -d org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder"
        # cvs -d :pserver:anonymous@dev.eclipse.org:/cvsroot/eclipse ${quietCVS} ex -r ${basebuilderBranch} -d org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder
        # TODO: make cvs user/protocol/host variables so can be rrun remotely also
         cvs -d :local:/cvsroot/eclipse ${quietCVS} ex -r ${basebuilderBranch} -d org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder
        checkForErrorExit $? "Could not check out basebuilder"
        #echo "cvs export cmd: ${cmd}"
        #"${cmd}"
    #else
        #    echo "base builder already existed, so taking as accurate. Remember to delete it when fresh version needed."
    #fi
    echo "DEBUG: current directory as exiting updateBaseBuilder ${PWD}"
    echo "[end] [`date +%H\:%M\:%S`] getting org.eclipse.releng.basebuilder using tag (or branch): ${basebuilderBranch}"

}


updateEclipseBuilder() {

    echo "[`date +%H\:%M\:%S`] get ${eclipsebuilder} using tag or branch: ${eclipsebuilderBranch}"

     # get fresh script. This is one case, we must get directly from repo since the purpose of the script 
     # is to get the eclipsebuilder! 
    wget -O getEclipseBuilder.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/getEclipseBuilder.sh?h=master
    chmod +x getEclipseBuilder.sh 
    
    # execute (in current directory) ... depends on some "exported" properties. 
    ./getEclipseBuilder.sh
    
    checkForErrorExit $? "Failed to get the Eclipse Buidler"
}


runSDKBuild () 
{

    echo "Starting runSDKBuild"
    echo "[start] [`date +%H\:%M\:%S`] setting eclipse ${eclipsestream}-I-Builds"
    echo "DEBUG: current directory: ${PWD}"

    if [ -d "${supportDir}" ]
    then
        cd $supportDir
        echo "Changed to directory ${PWD}"
    else
        echo "Cound not cd to ${supportDir}"
        exit 1
    fi

    echo "DEBUG: current directory for build: ${PWD}" 
   
    # TODO: should remove buildType (and others) and/or fail if not defined yet.
    buildType=I
    buildId=$buildType$date-$time
    buildLabel=$buildId
    buildfile=$supportDir/$eclipsebuilder/buildAll.xml
    mapVersionTag=R4_HEAD
    bootclasspath="/shared/common/j2sdk1.4.2_19/jre/lib/rt.jar:/shared/common/j2sdk1.4.2_19/jre/lib/jsse.jar:/shared/common/j2sdk1.4.2_19/jre/lib/jce.jar"
    bootclasspath_15="/shared/common/jdk-1.5.0_16/jre/lib/rt.jar:/shared/common/jdk-1.5.0_16/jre/lib/jsse.jar:/shared/common/jdk-1.5.0_16/jre/lib/jce.jar"
    bootclasspath_16="/shared/common/jdk1.6.0_27.x86_64/jre/lib/rt.jar:/shared/common/jdk1.6.0_27.x86_64/jre/lib/jsse.jar:/shared/common/jdk1.6.0_27.x86_64/jre/lib/jce.jar"
    bootclasspath_foundation="/shared/common/org.eclipse.sdk-feature2/libs/ee.foundation-1.0.jar"
    bootclasspath_foundation11="/shared/common/org.eclipse.sdk-feature2/libs/ee.foundation.jar"
    # https://bugs.eclipse.org/bugs/show_bug.cgi?id=375976, and 
    # https://bugs.eclipse.org/bugs/show_bug.cgi?id=376029
    OSGiMinimum11="/shared/common/org.eclipse.sdk-feature2/libs/ee.minimum.jar"
    OSGiMinimum12="/shared/common/org.eclipse.sdk-feature2/libs/ee.minimum-1.2.0.jar"

    javadoc="-Djavadoc16=/shared/common/jdk1.6.0_27.x86_64/bin/javadoc"
    
    skipPerf="-Dskip.performance.tests=true"
    skipTest="-Dskip.tests=true"
      
    # 'sign' works by setting as anything if desire signing, 
    # else, comment out. Comment out now to save time. 
    sign="-Dsign=true"
    
    # The cpAndMain is used to launch antrunner app (instead of using eclipse executable
    cpLaunch=$( find $relengBaseBuilderDir/plugins -name "org.eclipse.equinox.launcher_*.jar" | sort | head -1 )
    cpAndMain="$cpLaunch org.eclipse.equinox.launcher.Main"
    echo "DEBUG: cpLaunch: ${cpLaunch}"
    echo "DEBUG: cpAndMain: ${cpAndMain}"

    
    # hudson is an indicator of running on build.eclipse.org
    hudson="-Dhudson=true"

    echo "DEBUG: in runSDKBuild buildfile: $buildfile"
        
    # NOTE: the builder (or, some part if it) appears to 
    # REQUIRE Java 1.6, but its not obivous
    # See bug https://bugs.eclipse.org/bugs/show_bug.cgi?id=375807#c50 
    #
    # Remember that setting -debug will turn on debug for ant, which produces 
    # WAY too much output.    
    cmd="${JAVA_HOME}/bin/java -Xmx1000m -enableassertions \
        -cp $cpAndMain \
    -data $buildRoot/workspace-eclipse4 \
        -application org.eclipse.ant.core.antRunner  \
        -buildfile $buildfile \
        -DbuildType=$buildType \
        -DeclipseStream=$eclipseStream \
        -Dbuilddate=$date \
        -Dbuildtime=$time \
        -DbuildId=$buildId \
        -Dbuildid=$buildId \
        -DbuildLabel=$buildLabel \
        -Dbase=$buildDir/40builds \
        -DmapVersionTag=$mapVersionTag \
        -Dorg.eclipse.update.jarprocessor.pack200=${pack200dir} \
        -Declipse.p2.MD5Check=false \
        $skipPerf \
        $skipTest \
        $hudson \
        -DJ2SE-1.5=$bootclasspath_15 \
        -DJ2SE-1.4=$bootclasspath \
        -DCDC-1.0/Foundation-1.0=$bootclasspath_foundation \
        -DCDC-1.1/Foundation-1.1=$bootclasspath_foundation11 \
        -DOSGi/Minimum-1.0=$OSGiMinimum11 \
        -DOSGi/Minimum-1.1=$OSGiMinimum11 \
        -DOSGi/Minimum-1.2=$OSGiMinimum12 \
        -DJavaSE-1.6=$bootclasspath_16 \
        -DlogExtension=.xml \
        $javadoc \
        $sign \
        $repoCache \
        -DgenerateFeatureVersionSuffix=true \
        -Djava15home=${java15home} \
        -DupdateSite=${localUpdateSite} \
        -DpostingDirectory=$postingDirectory \
        -DequinoxPostingDirectory=$equinoxPostingDirectory"


    echo "INFO: save copy of command, to enable restarting into ${supportDir}/${eclipsebuilder}/command.txt"
    echo $cmd > $supportDir/$eclipsebuilder/command.txt
    # echo cmd to log/console
    echo "cmd: $cmd"
    # finally, start the java job
    $cmd  
     
}



tagRepo () {
    echo "DEBUG: starting tagRepo"
    pushd ${PWD}
    # we assume we already got the eclipsebuilder successfully
    # and we use the "working" version copied from gitClones
    releasescriptpath=$builderDir/scripts
   
    echo "DEBUG: using script in ${releasescriptpath}/git-release.sh"
    # remember, -committerId "$committerId" not required on build.eclipse.org
    # will need to do more if/when we make it a variable property (such as for 
    # committers running remotely, or even non-committers runnning remotely.
    #
    tagRepocmd="/bin/bash ${releasescriptpath}/git-release.sh -relengBranch $relengBranch \
        -relengMapsProject $relengMapsProject \
        -relengRepoName $relengRepoName \
        -buildType $buildType \
        -gitCache $gitCache \
    -buildRoot $buildRoot \
        -gitEmail \"$gitEmail\" -gitName \"$gitName\" \
        -timestamp $timestamp -oldBuildTag $oldBuildTag -buildTag $buildTag \
        -submissionReportFilePath $submissionReportFilePath \
        -tag $tag "

    echo "tag repo command: $tagRepocmd" 

    $tagRepocmd

    exitCode=$?
        echo
        echo "   ERROR. Autotagging exit code: ${exitCode} "
        echo
    return $exitCode
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
            "-relengBranch")
                relengBranch="$2"; shift;;
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
        echo "DEBUG: relengBranch: ${relengBranch}"
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

    relengBranch=${relengBranch:-R4_HEAD}
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
    export eclipsebuilderBranch=master

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

    #TODO: for 3.8 builds, use "drops" for eclipse  
    postingDirectory=${siteDir}/eclipse/downloads/drops4
    # TODO: for 3.8 builds, use "drops3" for equinox, and 
    # do not publish to downloads, but leave on build machine
    # (for a bit) in case someone wants to "compare" them
    equinoxPostingDirectory=${siteDir}/equinox/drops
    localUpdateSite=${siteDir}/updates
    buildResults=$postingDirectory/$buildTag
    submissionReportFilePath=$buildResults/report.txt


    # these don't seem right (not sure what they are)?
    # currently ends up being 
    # .../eclipse4/build/40builds/targets
    # and contains the ?local repo? (not runnable) for org.eclipse.emf.common, etc.
    # in directories named, for example,
    # as .../eclipse4/build/40builds/targets/local-repo-I20120331-0050
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

    sdkResults=$buildDir/40builds/$buildTag/$buildTag
    sdkBuildDirectory=$buildDir/40builds/$buildTag

    relengBaseBuilderDir=$supportDir/org.eclipse.releng.basebuilder



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
    echo "DEBUG: relengBranch ${relengBranch}"
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
    echo "WARNING: no oldBuildTag found. Set to NONE"
    oldBuildTag="NONE"
fi
echo "Last build: $oldBuildTag"
echo $buildTag >$buildRoot/${buildType}build.properties





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


# temp hard to remove completely, as sometimes hard to 
# remove some .nsf files 
# TODO: find out if that's become some process is running? 
#        should we wait and try again? (don't seem to need to, in this case). 
rm -fr ${VERBOSE_REMOVES} "${buildRoot}/build/supportDir/src"


runSDKBuild
checkForErrorExit $? "Failed while building Eclipse-SDK"

