#!/usr/bin/env bash

# use of this script requires our WTP addRepoProperties app to have already been added to eclipse instance.
# TODO: we could probably integrate and always call 'install-relengTools.sh' for ease? Just a little longer? and might update, when not intended or expected (e.g. untested changes?)
#${RELENG_CONTROL}/install-relengTools.sh

APP_NAME=org.eclipse.wtp.releng.tools.addRepoProperties

devworkspace=./workspace

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


#REPO="/shared/webtools/committers/wtp-R3.3.0-I/20101209114749/S-3.3.0M4-20101209114749/repository"
#BUILD_BRANCH=R3.3.0
#BUILD_ID=S-3.3.0M4-20101209114749
#STATS_TAG_SUFFIX=_indigo_M4
#STATS_TAG_VERSIONINDICATOR=/indigo

REPO=$1
BUILD_BRANCH=$2
BUILD_ID=$3
STATS_TAG_VERSIONINDICATOR=$4
STATS_TAG_SUFFIX=$5

if [[ -z "${REPO}" ]]
then
  echo "ERROR: this script requires a repository to add properties to.";
  exit 1;
fi

echo "BUILD_BRANCH: ${BUILD_BRANCH}";
echo "BUILD_ID: ${BUILD_ID}";
echo "STATS_TAG_SUFFIX: ${STATS_TAG_SUFFIX}";

if [[ ( ! ( -z "${BUILD_BRANCH}" ) ) && ( ! ( -z "${BUILD_ID}" ) ) ]]
then
 MIRRORURL="/webtools/downloads/drops/${BUILD_BRANCH}/${BUILD_ID}/repository/"
else
 echo "WARNING: no mirror URL specified.";
 MIRRORURL=""
fi

if [ ! -z $MIRRORURL ]
then
   MIRRORURL_ARG="http://www.eclipse.org/downloads/download.php?format=xml&file=${MIRRORURL}"
else
    MIRRORURL_ARG=""
fi

# remember, the '&' should NOT be unescaped here ... the p2 api (or underlying xml) will escape it.
devArgs="$ibmDevArgs \
-Dp2MirrorsURL=${MIRRORURL_ARG} \
-DartifactRepoDirectory=${REPO}  \
-Dp2StatsURI=http://download.eclipse.org/stats/webtools/repository${STATS_TAG_VERSIONINDICATOR} -DstatsArtifactsSuffix="${STATS_TAG_SUFFIX}" -DstatsTrackedArtifacts=org.eclipse.wst.jsdt.feature,org.eclipse.wst.xml_ui.feature,org.eclipse.wst.web_ui.feature,org.eclipse.jst.enterprise_ui.feature"


echo "dev:          " $0
echo "devworkspace: " $devworkspace
echo "devJRE:       " $devJRE
echo "devArgs:      " $devArgs
echo "APP_NAME:     " $APP_NAME
#$devJRE -version
echo


if [ -n ${ECLIPSE_EXE} -a -x ${ECLIPSE_EXE} ]
then
   ${ECLIPSE_EXE} --launcher.suppressErrors -nosplash -console -data $devworkspace -application ${APP_NAME} ${OTHER_ARGS} -vm $devJRE -vmargs $devArgs
   RC=$?
else
   echo "ERROR: ECLIPSE_EXE is not defined to executable eclipse"
   RC=1001
fi
exit $RC