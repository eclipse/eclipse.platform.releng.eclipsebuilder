#!/usr/bin/env bash

 getEclipseBuilder () {
     
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
     # ensure exists, in case not
     echo "DEBUG: gitCache: ${gitCache}"
     mkdir -p $gitCache

     echo "at start of getEclipseBuilder, current directtory is ${PWD}"
     
     cd $gitCache
     
     echo "DEBUG: changed direcotry in getEclipseBuilder to ${PWD}"
  
        repodirectory=$gitCache/$eclipsebuilderRepo 
        # in this case, project is in "root" of repo
        projectdirectory=$gitCache/$eclipsebuilder 
        echo "DEBUG: repodirectory: $repodirectory"
        if [[ ! -d "${repodirectory}" ]] 
        then
                echo "DEBUG: eclipsebuilder repo did not exist, so will clone"
                # TODO: make protocol/user etc variables?
                fullRepoURL="git://git.eclipse.org/gitroot/platform/${eclipsebuilderRepo}.git"
                #             git://git.eclipse.org/gitroot/platform/eclipse.platform.releng.eclipsebuilder.git
                echo "DEBUG: fullRepoURL: $fullRepoURL"
                echo "DEBUG: git clone $fullRepoURL"
                git clone $fullRepoURL
                cd $repodirectory
                git config --add user.email "$gitEmail"
                git config --add user.name "$gitName"
        else 
            echo "INFO: directory already exists: ${repodirectory}"
        fi
        
        cd $projectdirectory
        echo "DEBUG:  changed direcotry in getEclipseBuilder to ${PWD}"
        echo "git checkout $eclipsebuilderBranch"
        git checkout $eclipsebuilderBranch
        echo "git pull"
        git pull
        popd
        echo "DEBUG: at exit of getEclipseBuilder, current directtory is ${PWD}"
}

getEclipseBuilder

