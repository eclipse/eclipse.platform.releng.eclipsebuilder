#!/usr/bin/env bash

# remember to leave no slashes on commonVariations in source command,
# so that users path is used to find it (first). But, path on
# commonComputedVariables means we expect to execute only our
# version

if [ -z $BUILD_INITIALIZED ]
then
# if releng_control not set, we assume we are already in releng_control directory
   if [ -z $RELENG_CONTROL ]
   then
        RELENG_CONROL=`pwd`
   fi
   pushd .
   cd ${RELENG_CONTROL}
   source commonVariations.shsource
   source ${RELENG_CONTROL}/commonComputedVariables.shsource
   popd
fi

# For most ant tasks, we want Java 5
export JAVA_HOME=${JAVA_5_HOME}

ANT_CMD="${ANT_HOME}/bin/ant"
exec "$ANT_CMD" "$@"
