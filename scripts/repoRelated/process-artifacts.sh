#!/usr/bin/env bash
# Utility to invoke p2.process.artifacts via eclipse antrunner
# First argument must be the absolute directory path to the
# (simple) artifact repository.

repoDirLocation=$1

echo "   Final p2 processing artifacts to pack: $repoDirLocation"

# For now, we will assume buildRoot has been exported by
 # calling process (if they want a non default value).
buildRoot=${buildRoot:-/shared/eclipse/eclipse4I}
devworkspace="${buildRoot}"/workspace-process-artifacts

if [ ! -d "${buildRoot}" ]
then
    echo "ERROR: buildRoot was not an existing directory as expected: ${buildRoot}"
    exit 1
fi

# For most uses, this directory does not HAVE to literally be
# the eclipseBuider. It is in production, but for testing, it can
# be any directory where ${ECLIPSEBUILDER_DIR}/scripts/repoRelated are located.
ECLIPSEBUILDER_DIR=${ECLIPSEBUILDER_DIR:-${buildRoot}/build/supportDir/org.eclipse.releng.eclipsebuilder}

if [ ! -d "${ECLIPSEBUILDER_DIR}/scripts/repoRelated" ]
then
    echo "ERROR: builder scripts was not an existing directory as expected: ${ECLIPSEBUILDER_DIR}/scripts/repoRelated"
    exit 1
fi
# note we need the -f (file) argument here, since this is intened to be "the whole" argument to ant.
BUILDFILESTR="-f ${ECLIPSEBUILDER_DIR}"/scripts/repoRelated/process-artifacts.xml
# specify devworkspace and JRE to use to runEclipse
# remember, we want to use Java 5 for processing artifacts.
# Ideally same one used to pre-condition (normalize, -repack)
# the jars in the first place.
#JAVA_5_HOME=${JAVA_5_HOME:-/home/shared/orbit/apps/ibm-java2-i386-50/jre}
JAVA_5_HOME=${JAVA_5_HOME:-/shared/common/jdk-1.5.0-22.x86_64/jre}
JAVA_6_HOME=${JAVA_6HOME:-/shared/common/jdk1.6.0_27.x86_64}

#still use for java15home for M builds, for now
javaPackAndSignVMhome=${java16home}
if [[ $buildType == "M" ]] 
then
     javaPackAndSignVMhome=${java15home}
fi
    
export JAVA_HOME=${javaPackAndSignVMhome}

devJRE="${JAVA_HOME}"/bin/java

if [ ! -n ${devJRE} -a -x ${devJRE} ]
then
    echo "ERROR: could not find (or execute) JRE were expected: ${devJRE}"
    exit 1
else
    # display version, just to be able to log it.
    echo "JRE Location and Version: ${devJRE}"
    echo $( $devJRE -version )
fi

# in theory, could "get" a pack200 processor from other places,
# so this check may not always be appropriate?
# But, will be a good sanity check for now
PACK200_DIR=${javaPackAndSignVMhome}/bin

if [ ! -x "${PACK200_DIR}/pack200" ]
then
    echo "ERROR: pack200 not found (or, not executable) where expected: ${PACK200_DIR}"
    exit 1
else
    echo "pack200 version: "
    echo $( ${PACK200_DIR}/pack200 -V )
fi

# remember, the Eclipse install must match the VM used (e.g. both 64 bit, both 32 bit, etc).
ECLIPSE_EXE=${ECLIPSE_EXE:-/shared/eclipse/eclipsesdk372/eclipse/eclipse}

if [ ! -n ${ECLIPSE_EXE} -a -x ${ECLIPSE_EXE} ]
then
    echo "ERROR: ECLIPSE_EXE is not defined or not executable: ${ECLIPSE_EXE}"
    exit 1001
fi


if [[ -d "${repoDirLocation}" ]]
then
    echo "INFO: processing artifacts in code repo: $repoDirLocation";
    if [ -n ${ECLIPSE_EXE} -a -x ${ECLIPSE_EXE} ]
    then
        devArgs="-DrepoDirLocation=${repoDirLocation}"
        echo "   Don't panic! Processing artifacts can take a long time (such as 15 minutes or more)."
        echo
        ${ECLIPSE_EXE}  --launcher.suppressErrors  -nosplash -console -data $devworkspace -application org.eclipse.ant.core.antRunner $BUILDFILESTR ${extraArgs} -vm $devJRE -vmargs $devArgs
        RC=$?
    else
        echo "ERROR: ECLIPSE_EXE is not defined to executable eclipse"
        RC=1
    fi

    # bit of a hueristic here, but if there are any jar.pack.gz files of zero length, that means
    # they were invalid, and while we should have already removed them from metadata (if they were
    # there, at all), we'll remove the physical files too, to help avoid confusion.
    find "${repoDirLocation}" -size 0 -name "*.jar.pack.gz" -ls -exec rm '{}' \;

    exit $RC
else
    echo "ERROR: the specified artifact repository directory does not exist: $repoDirLocation";
    RC=1
fi


if [ $RC != 0 ]
then
    echo "ERROR: pack processing did not operate as expected. Exiting the promote script early."
    exit $RC
fi

exit 0

