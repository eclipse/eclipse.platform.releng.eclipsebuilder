#!/usr/bin/env bash

APP_NAME=org.eclipse.equinox.p2.director

OTHER_ARGS="-metadataRepository http://download.eclipse.org/webtools/releng/repository/ -artifactRepository http://download.eclipse.org/webtools/releng/repository/ -installIU org.eclipse.wtp.releng.tools.feature.feature.group"

devworkspace=~/workspace-addRepoProperties

# remember to leave no slashes on filename in source command,
# (the commonVariations.shsource file, that is)
# so that users path is used to find it (first)
if [ -z $BUILD_INITIALIZED ]
then
   source commonVariations.shsource
   source ${RELENG_CONTROL}/commonComputedVariables.shsource
fi

export JAVA_HOME=${JAVA_6_HOME}
devJRE=$JAVA_HOME/jre/bin/java

ibmDevArgs="-Xms128M -Xmx256M -Dosgi.ws=gtk -Dosgi.os=linux -Dosgi.arch=x86" 

devArgs=$ibmDevArgs

echo "dev:          " $0
echo "devworkspace: " $devworkspace
echo "devJRE:       " $devJRE
echo "OTHER_ARGS:   " ${OTHER_ARGS}
#$devJRE -version
echo

${ECLIPSE_EXE} --launcher.suppressErrors  -nosplash -console -data $devworkspace -application ${APP_NAME} ${OTHER_ARGS} -vm $devJRE -vmargs $devArgs
