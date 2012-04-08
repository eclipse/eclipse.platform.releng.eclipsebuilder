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

# temp test
export CVSROOT=:local:/cvsroot/eclipse

# temp hard to remove up from, using linux, as ant sometimes fail 
# to remove .nsf files
rm -fr /shared/eclipse/eclipse4/build/supportDir/src

#default values, overridden by command line
writableBuildRoot=/shared/eclipse/eclipse4
mkdir -p "${writableBuildRoot}"
export buildDir=$writableBuildRoot/build
mkdir -p "${buildDir}"

relengMapsProject=org.eclipse.releng
relengRepoName=eclipse.platform.releng.maps

# This is eclipsebuilder name on disk, traditionally org.eclipse.releng.eclipsebuilder
# Though now in git, the repo (and effective project name) is eclipse.platform.releng.eclipsebuilder 
# See https://bugs.eclipse.org/bugs/show_bug.cgi?id=374974 for details, 
# especially https://bugs.eclipse.org/bugs/show_bug.cgi?id=374974#c28
export eclipsebuilder=org.eclipse.releng.eclipsebuilder
export eclipsebuilderRepo=eclipse.platform.releng.eclipsebuilder

relengBranch=R4_HEAD
buildType=I
date=$(date +%Y%m%d)
time=$(date +%H%M)
timestamp=$date$time

export gitEmail=e4Build
export gitName=e4Builder-R4

# used in auto-tagging
# normally set true here, for production, but then 
# a nightly build would set it to false
tag=true

eclipseStream=4.2
basebuilderBranch=R4_2_primary
# relies on export, since getEclipseBuilder is seperate script, 
# and it does not use "command line pattern"
export eclipsebuilderBranch=R4_2_primary

# common properties
# Would have to run under Java 1.5, to make sure 'sign' (which uses jar processor) 
# and eventual "pack200" can all be unpacked with 1.5. 
# long term, we can launch those tasks in seperate process, or some other better way.
java15home=/shared/common/jdk-1.5.0-22.x86_64
#java15home=/shared/orbit/apps/ibm-java2-i386-50/jre
java16home=/shared/common/sun-jdk1.6.0_21_x64
pack200dir=${java15home}/bin

if [ ! -x "${pack200dir}/pack200" ]
then
    echo "ERROR: pack200 not found (or, not executable) where expected: ${pack200dir}"
    exit 1
fi

export JAVA_HOME=${java16home} 
echo "DEBUG: in testsinging script: JAVA_HOME: ${JAVA_HOME}"

buildTimestamp=${date}-${time}
buildTag=$buildType$buildTimestamp



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
#export quietCVS=${quietCVS:--Q}
#export quietCVS=${quietCVS:--q}
export quietCVS=${quietCVS:-" "}



arch="x86_64"
archProp="-x86_64"
archJavaProp=""
processor=$( uname -p )
if [ $processor = ppc -o $processor = ppc64 ]; then
    archProp="-ppc"
    archJavaProp="-DarchProp=-ppc"
    arch="ppc"
fi

#
#  control various aspects of the build
#


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
        "-root")
            writableBuildRoot="$2"; shift;;
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

export supportDir=${buildDir}/supportDir
mkdir -p "${supportDir}"

if [ -z "$gitCache" ]; then
    export gitCache=$supportDir/gitCache
    # ensure exists, in case not
    mkdir -p $gitCache
    echo "INFO: value of gitCache: ${gitCache}"
else
    echo "WARNING: unexpected value of gitCache already defined: ${gitCache}"
fi

export builderDir=${supportDir}/$eclipsebuilder
# remember: do not "mkdir" for builderDir since presence/absence 
# might be used later to determine if fresh check out needed or not.
# mkdir -p "${builderDir}"
echo "INFO: value of builderDir: ${builderDir}"

if [ "$buildType" = "N" ]; then
    echo "DEBUG: tag forced to false due to being an N build"
    tag=false
fi

if [ -f $writableBuildRoot/${buildType}build.properties ]
then
    oldBuildTag=$( cat $writableBuildRoot/${buildType}build.properties )
else
    oldBuildTag="NONE"
fi
echo "Last build: $oldBuildTag"
echo $buildTag >$writableBuildRoot/${buildType}build.properties
dropDir=4.2.0
localDropDirectory=${buildDir}/downloads/drops/$dropDir
mkdir -p $localDropDirectory
buildResults=$localDropDirectory/$buildTag
mkdir -p $buildResults
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
transformedRepo=${targetDir}/transformedRepo

# should not set globally to java via -Dproperty=value, since eclipsebuilder 
# assumes different scopes and changes this value for direct calls to generatescripts
buildDirectory=${buildDir}/$buildTag

#rembember, don't point to e4Build user directory
sdkTestDir=${writableBuildRoot}/sdkTests/$buildTag

sdkResults=$buildDir/40builds/$buildTag/$buildTag
sdkBuildDirectory=$buildDir/40builds/$buildTag

relengBaseBuilderDir=$supportDir/org.eclipse.releng.basebuilder
buildDirEclipse="$buildDir/eclipse"

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

    if [ -d "${supportDir}" ]
    then
        cd "${supportDir}"
        echo "   changed current directory to ${PWD}"
    else
        echo "   ERROR: support directory did not exist as expected."  
        exit 1
    fi 

    echo "DEBUG: checking existence"
    
    if [ -d ${relengBaseBuilderDir} ]
     then
           echo "removing previous version of base builder, to be sure it is fresh, to see if related to to see if fixes bug 375780"
           rm -fr ${VERBOSE_REMOVES} ${relengBaseBuilderDir}
     fi

    if [[ ! -d "${relengBaseBuilderDir}" ]] 
    then
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
    else
        echo "base builder already existed, so taking as accurate. Remember to delete it when fresh version needed."
    fi


    # The cpAndMain is used to launch antrunner app (instead of using eclipse executable
    cpLaunch=$( find $relengBaseBuilderDir/plugins -name "org.eclipse.equinox.launcher_*.jar" | sort | head -1 )
    cpAndMain="$cpLaunch org.eclipse.equinox.launcher.Main"
    echo "DEBUG: cpLaunch: ${cpLaunch}"
    echo "DEBUG: cpAndMain: ${cpAndMain}"
}


updateEclipseBuilder() {

    echo "[`date +%H\:%M\:%S`] get ${eclipsebuilder} using tag or branch: ${eclipsebuilderBranch}"

     # get fresh script. This is one case, we must get directly from repo since the purpose of the script 
     # is to get the eclipsebuilder! 
    wget -O getEclipseBuilder.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/getEclipseBuilder.sh?h=R4_2_primary
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
    
    # should skipPack to save time. This is the pack that 
    # produces the jar.pack.gz files. Need to run it under Java 5, etc.
    #skipPack="-DskipPack=true"
    
    # 'sign' works by setting as anything if desire signing, 
    # else, comment out. Comment out now to save time. 
    sign="-Dsign=true"
    
    #TODO: assume this would eventually be downloads? Or is it a temporary location, on 
    # build machine, which is later copied over to downloads? 
    postingDirectory=$supportDir
    
    # hudson is an indicator of running on build.eclipse.org
    hudson="-Dhudson=true"

    echo "DEBUG: in runSDKBuild buildfile: $buildfile"
        
    # NOTE: the builder (or, some part if it) appears to 
    # REQUIRE Java 1.6, but its not obivous
    # See bug https://bugs.eclipse.org/bugs/show_bug.cgi?id=375807#c50     
    cmd="${JAVA_HOME}/bin/java -Xmx1000m -enableassertions \
        -cp $cpAndMain \
        -data $writableBuildRoot\workspace-eclipse4 \
        -debug \
        -application org.eclipse.ant.core.antRunner  \
        -buildfile $buildfile \
        -DbuildType=$buildType \
        -Dbuilddate=$date \
        -Dbuildtime=$time \
        -DbuildId=$buildId \
        -Dbuildid=$buildId \
        -DbuildLabel=$buildLabel \
        -Dbase=$buildDir/40builds \
        -DupdateSite=$supportDir/updates/4.2-I-builds \
        -DmapVersionTag=$mapVersionTag \
        -Dorg.eclipse.update.jarprocessor.pack200=${pack200dir} \
        -Declipse.p2.MD5Check=false \
        $skipPerf \
        $skipTest \
        $skipPack \
        $skipSourceBuild \
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
        -DpostingDirectory=$postingDirectory"


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
        -root $writableBuildRoot \
        -gitEmail \"$gitEmail\" -gitName \"$gitName\" \
        -timestamp $timestamp -oldBuildTag $oldBuildTag -buildTag $buildTag \
        -submissionReportFilePath $submissionReportFilePath \
        -tag $tag "

    echo "tag repo command: $tagRepocmd" 

    $tagRepocmd

    exitCode=$?
    if [ "${exitCode}" -ne "0" ]
    then
        echo
        echo "   ERROR. exit code: ${exitCode} Autotagging failed. See log."
        echo
        # eventually, of course, send to platform-releng-dev@eclipse.org
        # with pointer to the log. 
        # remove "TEST" before production runs.
        mailx -s "$eclipseStream SDK TEST Build: $buildTag auto tagging failed" david_williams@us.ibm.com <<EOF
   
    Auto tagging failed. See log. 
    Build halted.
    
EOF
        exit "${exitCode}"
    fi

    # remove "TEST" before production runs.
    mailx -s "$eclipseStream SDK TEST Build: $buildTag submission" david_williams@us.ibm.com <$submissionReportFilePath
    #mailx -s "$eclipseStream SDK Build: $buildTag submission" platform-releng-dev@eclipse.org <$submissionReportFilePath
    popd
    echo "DEBUG: ending tagRepo"
}

updateBaseBuilder
checkForErrorExit $? "Failed while updating Base Buidler"

updateEclipseBuilder
checkForErrorExit $? "Failed while updating Eclipse Buidler"

tagRepo
checkForErrorExit $? "Failed during auto tagging"

runSDKBuild
checkForErrorExit $? "Failed while building Eclipse-SDK"

