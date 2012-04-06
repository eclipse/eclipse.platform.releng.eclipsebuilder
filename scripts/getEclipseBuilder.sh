#!/usr/bin/env bash

# This script removes old eclipse builder, to make sure we start with 
# fresh copy. Then gets or updates clone in gitClones, then uses that 
# to copy back to the "working copy" of eclipse builder. 

# DEBUG controls verbosity of little "state and status" messages
# normally would be false during production
export DEBUG=${DEBUG:-false}
#export DEBUG=${DEBUG:-true}
echo "DEBUG: $DEBUG"

# VERBOSE_REMOVES needs to be empty or literally 'v', since
# simply makes up part of "rm" command when directories removed.
VERBOSE_REMOVES=${VERBOSE_REMOVES:-}
#VERBOSE_REMOVES=${VERBOSE_REMOVES:--v}
echo "VERBOSE_REMOVES: $VERBOSE_REMOVES"

# simple utility to check return code and exit if non-zero 
function checkForErrorExit ()
{
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


# debugVar is simply utility to display variables and values that is 
# a little lighter weight that a full <echoproperties />
# TODO: an alternative might be to have a system of prefixing variables to 
# with meaning full prefixes so that <echoproperties>... could still be used 
# with meaningfuil subset. But, large change. For example, "basedirectory" could 
# become "eclipsebuilder.basedirectory"
function debugVar ()
{
    if [[ "${DEBUG}" == "true" ]]
    then
        variablenametodisplay=$1
        eval variableValue=\$${variablenametodisplay}
        echo "DEBUG VAR: ${variablenametodisplay}: ${variableValue}"
    fi 
}
function debugMsg ()
{
    if [[ "${DEBUG}" == "true" ]]
    then
        message=$1
        echo "DEBUG MSG: ${message}"
    fi 
}

function getEclipseBuilder () {
    debugMsg "     At start of getEclipseBuilder, current directory is ${PWD}"
    # pushd where we start from, so we end up returning to same direcotry
    pushd ${PWD}

    # we set these variables here, to allow standalone test, 
    #    but if they already exist (say via a previous export) 
    #    then we use the existing, exported value. 

    # by coincidendence, git repo and git project are named the same
    # but the working location it ends up on disk will be named its 
    # old traditional name or org.eclipse.releng.eclipsebuilder
    # for now. See bug 374974
    eclipsebuilder=${eclipsebuilder:-"org.eclipse.releng.eclipsebuilder"}
    eclipsebuilderRepo=${eclipsebuilderRepo:-"eclipse.platform.releng.eclipsebuilder"}
    eclipsebuilderBranch=${eclipsebuilderBranch:-"R4_2_primary"}
    gitEmail=${gitEmail:-"e4Build"}
    gitName=${gitName:-"e4Builder-R4"}
    # normally buildDir would be expected to be "passed in" via export, but
    # if not, we can start of PWD for local, standalone testing.
    buildDir=${buildDir:-"${PWD}/build"}
    supportDir=${supportDir:-"${buildDir}/supportDir"}
    gitCache=${gitCache:-"$supportDir/gitClones"}
    builderDir=${builderDir:-"${supportDir}/$eclipsebuilder"}

    debugVar eclipsebuilder
    debugVar eclipsebuilderRepo
    debugVar eclipsebuilderBranch
    debugVar gitEmail
    debugVar gitName
    debugVar buildDir
    debugVar supportDir
    debugVar gitCache
    debugVar builderDir
    # ensure exists, in case not
    mkdir -p $gitCache

    # removing eclipsebuilder, for now, to see if fixes bug 375780
    #builderDir is full path to eclipsebuilder
    if [[ -d "${builderDir}" ]] 
    then
        debugMsg "     Removing previous builderDir to make sure clean"
        rm -fr ${VERBOSE_REMOVES} "${builderDir}"
    else 
        debugMsg "     Previous builderDir did not exist, so nothing to remove"
    fi
    

    cd $gitCache

    debugMsg "INFO: changed direcotry in getEclipseBuilder to ${PWD}"
    
    repodirectory=$gitCache/$eclipsebuilderRepo 
    debugVar repodirectory
    # in this case, project is in "root" of repo
    projectdirectory=$gitCache/$eclipsebuilderRepo 
    debugVar projectdirectory
    debugMsg "testing existence of ${repodirectory}"
    if [[ ! -d "${repodirectory}" ]] 
    then
        debugMsg "eclipsebuilder repo, ${repodirectory}, did not exist, so will clone"
        # TODO: make protocol/user etc variables?
        fullRepoURL="git://git.eclipse.org/gitroot/platform/${eclipsebuilderRepo}.git"
        #             git://git.eclipse.org/gitroot/platform/eclipse.platform.releng.eclipsebuilder.git
        debugVar fullRepoURL
        debugMsg "git command: git clone $fullRepoURL"
        git clone $fullRepoURL
        cd $repodirectory
        git config --add user.email "$gitEmail"
        git config --add user.name "$gitName"
    else 
        echo "INFO: directory already exists: ${repodirectory}"
    fi

    cd $projectdirectory
    checkForErrorExit $? "Could not cd to $projectdirectory"
    debugMsg "changed direcotry in getEclipseBuilder to ${PWD}"
    debugMsg "git command: git checkout $eclipsebuilderBranch"
    git checkout $eclipsebuilderBranch
    checkForErrorExit $? "git checkout failed"
    debugMsg "git command: git pull"
    git pull
    checkForErrorExit $? "git pull failed"
        
    # assuming now all is fresh and current, copy the gitClone version back to 
    # the "real" builderDirectory
    debugMsg "     Will now copy cloned version back to \"real\" builderDir, ${builderDir}"
    mkdir -p "${builderDir}"
    rsync -a  "${repodirectory}"/* "${builderDir}"/ 
    
    popd
    debugMsg "     At exit of getEclipseBuilder, current directtory is ${PWD}"
}

getEclipseBuilder

