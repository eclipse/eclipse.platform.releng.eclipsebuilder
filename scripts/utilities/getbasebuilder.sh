#!/usr/bin/env bash

# utility script to get basebuilder. Must have locations, tags, etc., modified 
# for any particular use.

function getBasebuilderFromGit () {

    # specify branch or tag to retrieve
    # default to what we are currently using
    # basebuilderBranch=R3_7_maintenance
    basebuilderBranch=${basebuilderBranch:-R38M6PlusRC3D}

    # make and clean (if not new) the temporary directory to unzip into
    TEMP_LOC=tempcgitfiles

    # remove and recreate if it exists, so we know its fresh
    if [[ -d ${TEMP_LOC} ]]
    then
        rm -fr ${TEMP_LOC}
    fi

    mkdir -p ${TEMP_LOC}

    # This wget is the key part of this script, using the snapshot function of the cgit http interface.
    # It allows using the files from Git, without using Git.  
    # The name of the local zip file in wget command is arbitrary, but by having a unique name, based on branch or tag,  
    # allows them to cached locally (especially for tagged versions, since should never change, ideally).
    # TODO: would be a little quicker to see if we already have local cached copy of tagged version of zip
    wget --no-verbose -O basebuilder-${basebuilderBranch}.zip http://git.eclipse.org/c/platform/eclipse.platform.releng.basebuilder.git/snapshot/eclipse.platform.releng.basebuilder-${basebuilderBranch}.zip 2>&1

    # could/should put the basebuilder in to any existing directory, (where ever current scripts put it) 
    # but for demonstration or current case will use current directory
    LOC_ROOT=${PWD}

    unzip -q basebuilder-${basebuilderBranch}.zip -d ${TEMP_LOC}

    # TODO masterbuild script removes this too, so don't need here in that context
    # remove and recreate if it exists, so we know its fresh
    if [[ -d "${LOC_ROOT}/org.eclipse.releng.basebuilder"} ]]
    then
        rm -fr "${LOC_ROOT}/org.eclipse.releng.basebuilder"
    fi

    mkdir -p "${LOC_ROOT}/org.eclipse.releng.basebuilder"

    # copy basebuilder into directory is constant name, so rest of build script stays the same
    rsync -r ${TEMP_LOC}/eclipse.platform.releng.basebuilder-${basebuilderBranch}/  ${LOC_ROOT}/org.eclipse.releng.basebuilder

    # remove the tempoary directory
    # (but leaving for now, for demonstration/confirmation of what is fetched from git)
    # caution, if TEMP_LOC not defined, this may rm current directory?!
    # rm -fr ${TEMP_LOC}
    # rm  basebuilder-${basebuilderBranch}.zip

    # TODO: add error checking and exits in case there are issues
    # TODO: add echos so there is some "log" left of what was done?

}

getBasebuilderFromGit

