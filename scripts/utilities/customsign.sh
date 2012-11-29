#!/usr/bin/env bash

# Small utility to launch signing process, where we have more control over setting
# JAVA_HOME, etc.

# The first argument must be the absolute path to the file to sign.
# The second argument is tecnically optional, but most provide it so that
# once a file appears they know it will be the signed version.

# We put in lots of tests, just to be sure all is as expected.

# remember, we want to use Java 5 for processing artifacts and signing.
# (signing uses jarprocessor and does a pack200 -repack as part of the
# required conditioning before signing.
# Ideally use same VM (pack200) to normalize (-repack), sign, and pack
# the jars.
# 2012-11-29 Update: See bug 395320. We'll use Java 6 (for Kepler)
JAVA_5_HOME=${JAVA_5_HOME:-/shared/common/jdk-1.5.0-22.x86_64}
JAVA_6_HOME=${JAVA_6_HOME:-/shared/common/jdk1.6.0_27.x86_64}

export JAVA_HOME=${JAVA_5_HOME}

devJRE=$JAVA_HOME/bin/java

if [ ! -n ${devJRE} -a -x ${devJRE} ]
then
    echo "ERROR: could not find (or execute) JRE as expected: ${devJRE}"
    exit 1
else
    # display version, just to be able to log it.
    echo "JRE Location and Version: ${devJRE}"
    echo $( $devJRE -version )
fi

# in theory, could "get" a pack200 processor from other places,
# so this check may not always be appropriate?
# But, will be a good sanity check for now
PACK200_DIR=${JAVA_HOME}/bin

if [ ! -x "${PACK200_DIR}/pack200" ]
then
    echo "ERROR: pack200 not found (or, not executable) where expected: ${PACK200_DIR}"
    exit 1
else
    echo "pack200 version: "
    echo $( ${PACK200_DIR}/pack200 -V )
fi


fileToSign=$1
outputDir=$2

echo "JAVA_HOME: $JAVA_HOME"
echo "fileToSign: $fileToSign"
echo "outputDir: $outputDir"

if [ -z "${fileToSign}" ]
then
    echo "ERROR: the file to sign must be provided as the first argument: ${fileToSign}"
    exit 1
fi

if [ -f "${fileToSign}" ]
then
    echo "ERROR: the file to sign appears to not exist: ${fileToSign}"
    exit 1
fi

# remember, this script runs and exits quickly.
# The calling program must wait for output to appear in $outputDir
# or if the optional outputDir isn't provide, then must wait for the
# file itself to change.
/usr/bin/sign ${fileToSign} nomail $outputDir

rcode=$?

if [ "${rcode}" != "0" ]
then
    echo "ERROR: signing script exit with code: ${rcode}"
    echo "       You may not have permisssion to sign?"
    exit ${rcode}
fi

echo "INFO: signing queued"
exit 0




