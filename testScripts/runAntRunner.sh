#!/usr/bin/env bash

# Utility to invoke eclipse antrunner
#    the build file, if not build.xml, must be first argument
#    that can be followed be target or other arguments

source standardVariables.shsource

BUILDFILE=$1
if [ -e $BUILDFILE ]
then
    BUILDFILESTR=" -file $BUILDFILE"
    shift
else
    BUILDFILESTR=" -file build.xml"
fi

# use special $@ to keep all arguments quoted (instead of one big string)
extraArgs="$@"

echo
echo " BUILDFILESTR: $BUILDFILESTR"
if [ -n "${extraArgs}" ]
then
    echo "   extraArgs: ${extraArgs}"
    echo "      as it is right now, target name must be first \"extraArg\" if specifying one."
fi
echo


devworkspace="${BUILD_HOME}"/workspace-antRunner
devArgs=-Xmx256m

echo
echo "   dev script:   $0"
echo "   devworkspace: $devworkspace"
echo "   devArgs:      $devArgs"
echo

if [ -n ${ECLIPSE_EXE} -a -x ${ECLIPSE_EXE} ]
then 

    ${ECLIPSE_EXE}  --launcher.suppressErrors  -nosplash -console -data $devworkspace -application org.eclipse.ant.core.antRunner $BUILDFILESTR ${extraArgs} -vm $devJRE -vmargs $devArgs
    RC=$?
else
    echo "ERROR: ECLIPSE_EXE is not defined to executable eclipse"
    RC=1
fi 
exit $RC
