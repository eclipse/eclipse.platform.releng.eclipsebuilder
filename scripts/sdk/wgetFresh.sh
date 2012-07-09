#!/usr/bin/env bash

# gets a fresh copy of utility scripts

# codifying the branch (or tag) to use, so it can be set/chagned in one place
initScriptTag="h=master"

# to use a tag instead of branch, would be tag=X, such as 
# tag=vI20120417-0700, or in full form
# http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/wgetFresh.sh?tag=vI20120417-0700

source checkForErrorExit.sh

gitfile=makeBranch.sh
wget --no-verbose -O ${gitfile} http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/sdk/${gitfile}?$initScriptTag 2>&1;
checkForErrorExit $? "could not wget file: ${gitfile}"
gitfile=renameBuild.sh
wget --no-verbose -O ${gitfile} http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/sdk/${gitfile}?$initScriptTag 2>&1;
checkForErrorExit $? "could not wget file: ${gitfile}"
gitfile=checkForErrorExit.sh
wget --no-verbose -O ${gitfile} http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/sdk/${gitfile}?$initScriptTag 2>&1;
checkForErrorExit $? "could not wget file: ${gitfile}"

# get this script itself (would have to run twice to make use changes, naturally)
# and has trouble "writing over itself" so we put in a file with 'NEW' suffix
# but will remove it if no differences found.
# and a command line like the following works well

wget --no-verbose -O wgetFresh.NEW.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/sdk/wgetFresh.sh?$initScriptTag 2>&1;

differs=`diff wgetFresh.NEW.sh wgetFresh.sh`
echo "differs: ${differs}"
if [ -z "${differs}" ]
then 
    # 'new' not different from existing, so remove 'new' one
    rm wgetFresh.NEW.sh
else
    echo " " 
    echo "     wgetFresh.sh has changed. Compare with and consider replacing with wgetFresh.NEW.sh"
    echo "  "
fi

chmod +x *.sh


function checkForErrorExit ()
{
    # arg 1 must be return code, $?
    # arg 2 (remaining line) can be message to print before exiting due to non-zero exit code
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
        echo "   ERROR. exit code: ${exitCode}  ${message}"
        echo
        exit "${exitCode}"
    fi
}