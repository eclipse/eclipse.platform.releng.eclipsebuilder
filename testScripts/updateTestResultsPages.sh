#!/usr/bin/env bash

# Utility to invoke eclipse antrunner to update test index pages and 
# re-sync dl site.


# this is the single script to call that "does it all" to promote build 
# to update site, drop site, update index page on downlaods, and send mail to list.

# it requires three arguments
#    eclipseStream (e.g. 4.2 or 3.8) 
#    buildId       (e.g. N20120415-2015)


if [[ $# != 2 ]]
then
    # usage: 
    scriptname=$(basename $0)
    printf "\n\t%s\n" "This script, $scriptname requires three arguments, in order: "
    printf "\t\t%s\t%s\n" "eclipseStream" "(e.g. 4.2.0 or 3.8.0) "
    printf "\t\t%s\t%s\n" "buildId" "(e.g. N20120415-2015) "
    printf "\t%s\n" "for example," 
    printf "\t%s\n\n" "./$scriptname 4.2.0 N N20120415-2015"
    exit 1
fi

eclipseStream=$1
if [ -z "${eclipseStream}" ]
then
    echo "must provide EclipseStream as first argumnet, for this function $0"
    return 1;
fi


buildId=$2
if [ -z "${buildId}" ]
then
    echo "must provide buildId as second argumnet, for this function $0"
    return 1;
fi


    eclipseStreamMajor=${eclipseStream:0:1}
    buildType=${buildId:0:1}
    
    pathToDL=eclipse/downloads/drops
    if [[ $eclipseStreamMajor > 3 ]]
    then 
        pathToDL=eclipse/downloads/drops$eclipseStreamMajor
    fi


    buildRoot=${buildRoot:-/shared/eclipse/eclipse${eclipseStreamMajor}${buildType}}
    siteDir=${buildRoot}/siteDir

    fromDir=${siteDir}/${pathToDL}/${buildId}
    if [ ! -d "${fromDir}" ]
    then
        echo "ERROR: fromDir is not a direcotry? fromDir: ${fromDir}"
        return 1
    fi


# specify devworkspace and JRE to use to runEclipse
# remember, we want to use Java 5 for processing artifacts.
# Ideally same one used to pre-condition (normalize, -repack) 
# the jars in the first place. 
#JAVA_5_HOME=${JAVA_5_HOME:-/home/shared/orbit/apps/ibm-java2-i386-50/jre}
#JAVA_5_HOME=${JAVA_5_HOME:-${HOME}/jdks/ibm-java2-x86_64-50}
JAVA_6_HOME=${JAVA_6_HOME:-/shared/common/jdk-1.6.0_26.x86_64}

export JAVA_HOME=${JAVA_6_HOME}

devJRE=$JAVA_HOME/jre/bin/java

if [ ! -n ${devJRE} -a -x ${devJRE} ] 
then
    echo "ERROR: could not find (or execute) JRE were expected: ${devJRE}"
    exit 1
else
    # display version, just to be able to log it. 
    echo "JRE Location and Version: ${devJRE}"
    echo $( $devJRE -version )
fi

# remember, the Eclipse install must match the VM used (e.g. both 64 bit, both 32 bit, etc).
ECLIPSE_EXE=${ECLIPSE_EXE:-${buildRoot}/build/supportDir/org.eclipse.releng.basebuilder/eclipse}
# somehow, seems like this is often not executable ... I guess launcher jar usually used.
chmod -c +x $ECLIPSE_EXE

if [ ! -n ${ECLIPSE_EXE} -a -x ${ECLIPSE_EXE} ]
then
   echo "ERROR: ECLIPSE_EXE is not defined or not executable: ${ECLIPSE_EXE}"
   exit 1
fi 

BUILDFILE=${BUILDFILE:-${buildRoot}/build/supportDir/org.eclipse.releng.eclipsebuilder/testScripts/genTestIndexes.xml}

BUILDFILESTR="-f ${BUILDFILE}"
echo
echo " BUILDFILESTR: $BUILDFILESTR"

# provide blank, to get default
BUILDTARGET=" "

eclipseStreamMajor=${eclipseStream:0:1}

devworkspace="${buildRoot}"/workspace-updateTestResults
devArgs="-Xmx256m -Dhudson=true -DeclipseStream=${eclipseStream} -DeclipseStreamMajor=${eclipseStreamMajor} -DbuildId=${buildId}" 

echo
echo "   dev script:   $0"
echo "   devworkspace: $devworkspace"
echo "   devArgs:      $devArgs"
echo

if [ -n ${ECLIPSE_EXE} -a -x ${ECLIPSE_EXE} ]
then 

${ECLIPSE_EXE}  --launcher.suppressErrors  -nosplash -console -data $devworkspace -application org.eclipse.ant.core.antRunner $BUILDFILESTR  $BUILDTARGET -vm $devJRE -vmargs $devArgs
    RC=$?
else
    echo "ERROR: ECLIPSE_EXE is not defined to executable eclipse"
    RC=1
fi 
exit $RC
