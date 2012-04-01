#!/usr/bin/env bash

DEBUG=true

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
    debugMsg "at start of getEclipseBuilder, current directtory is ${PWD}"
    # pushd where we start from, so we end up returning to same direcotry
    pushd ${PWD}

    # we set these variables here, to allow standalone test, 
    #    but if they already exist (say via a previous export) 
    #    then we use the existing, exported value. 

    # by coincidendence, repo and project are named the same
    eclipsebuilder=${eclipsebuilder:-"eclipse.platform.releng.eclipsebuilder"}
    eclipsebuilderRepo=${eclipsebuilderRepo:-"eclipse.platform.releng.eclipsebuilder"}
    eclipsebuilderBranch=${eclipsebuilderBranch:-"R4_2_primary"}
    gitEmail=${gitEmail:-"e4Build"}
    gitName=${gitName:-"e4Builder-R4"}
    gitCache=${gitCache:-"${PWD}/temptestdir/gitClones"}

    debugVar eclipsebuilder
    debugVar eclipsebuilderRepo
    debugVar eclipsebuilderBranch
    debugVar gitEmail
    debugVar gitName
    debugVar gitCache
    # ensure exists, in case not
    mkdir -p $gitCache


    cd $gitCache

    debugMsg "changed direcotry in getEclipseBuilder to ${PWD}"
    
    repodirectory=$gitCache/$eclipsebuilderRepo 
    debugVar repodirectory
    # in this case, project is in "root" of repo
    projectdirectory=$gitCache/$eclipsebuilder 
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
    debugMsg "changed direcotry in getEclipseBuilder to ${PWD}"
    debugMsg "git command: git checkout $eclipsebuilderBranch"
    git checkout $eclipsebuilderBranch
    debugMsg "git command: git pull"
    git pull
    popd
    debugMsg "at exit of getEclipseBuilder, current directtory is ${PWD}"
}

getEclipseBuilder

