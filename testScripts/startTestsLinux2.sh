#!/usr/bin/env bash


# get the base builder (still in cvs)
updateBaseBuilder () {

    echo "[start] [`date +%H\:%M\:%S`] updateBaseBuilder getting org.eclipse.releng.basebuilder using tag (or branch): ${basebuilderBranch}"
    echo "DEBUG: current directory as entering updateBaseBuilder ${PWD}"
    if [ -d "${supportDir}" ]
    then
        cd "${supportDir}"
        echo "   changed current directory to ${PWD}"
    else
        echo "   ERROR: support directory did not exist as expected."  
        exit 1
    fi 
    
    if [[ -z "${relengBaseBuilderDir}" ]]
    then 
        echo "ERROR: relengBaseBuilderDir must be defined for this script, $0"
        exit 1
    fi
        if [[ -z "${basebuilderBranch}" ]]
    then 
        echo "ERROR: basebuilderBranch must be defined for this script, $0"
        exit 1
    fi
    
    echo "DEBUG: relengBaseBuilderDir: $relengBaseBuilderDir"
    echo "INFO: basebuilderBranch: $basebuilderBranch"
    
    #if [ -e ${relengBaseBuilderDir}/eclipse.ini ]
     # then
           #      echo "removing previous version of base builder, to be sure it is fresh, to see if related to to see if fixes bug 375780"
           #rm -fr ${VERBOSE_REMOVES} ${relengBaseBuilderDir}
     #fi
     
    # existence of direcotry, is not best test of existence, since 
    # sometimes the top level directory may still exist, while most files deleted,  
    # due to NFS filesystem quirks. Hence, we look for specific file, the eclispe.ini 
    # file. 
    if [[ ! -e "${relengBaseBuilderDir}/eclipse.ini" ]] 
    then
        # make directory in case doesn't exist ${relengBaseBuilderDir}
        mkdir -p "${relengBaseBuilderDir}"
        #echo "DEBUG: creating cmd"
        # TODO: for some reason I could not get this "in" an executable command ... not enough quotes, or something? 
        #cmd="cvs -d :pserver:anonymous@dev.eclipse.org:/cvsroot/eclipse ${quietCVS} ex -r ${basebuilderBranch} -d org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder"
        # cvs -d :pserver:anonymous@dev.eclipse.org:/cvsroot/eclipse ${quietCVS} ex -r ${basebuilderBranch} -d org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder
        # TODO: make cvs user/protocol/host variables so can be rrun remotely also
         cvs -d :local:/cvsroot/eclipse ${quietCVS} ex -r ${basebuilderBranch} -d org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder
         exitcode=$?
        #echo "cvs export cmd: ${cmd}"
        #"${cmd}"
    else
        echo "INFO: base builder already existed, so taking as accurate. Remember to delete it when fresh version needed."
        exitcode=0
    fi
    echo "DEBUG: current directory as exiting updateBaseBuilder ${PWD}"
    echo "[end] [`date +%H\:%M\:%S`] updateBaseBuilder getting org.eclipse.releng.basebuilder using tag (or branch): ${basebuilderBranch}"
    # note we save and return the return code from the cvs command itself. 
    # That is so we can complete, exit, and let caller decide what to do 
    # (to abort, retry, etc.) 
    return $exitcode
}

# make this listing, so we get layout logged
ls -lA --classify --group-directories-first

# same concepts as when running builds, but, different, since
# no longer running on "shared"
# WORKSPACE is hudson's variable to current jobs working area
    buildRoot=${buildRoot:-$WORKSPACE}
    
    # derived values (which effect default computed values) 
    # TODO: do not recall why I export these ... should live without, if possible
    export buildDir=${buildRoot}/build
    export siteDir=${buildRoot}/siteDir


    export supportDir=${buildDir}/supportDir
    mkdir -p $supportDir
    export relengBaseBuilderDir=$buildRoot/org.eclipse.releng.basebuilder
    export basebuilderBranch=R4_2_primary
    export eclipseBuilderDir=$buildRoot/org.eclipse.releng.eclipsebuilder
    
updateBaseBuilder 

# this command used to be on hudson itself, but had
# to move here, so we could get eclipsebuilder from 
# git, but then have the first thing done was to fetch 
# the basebuilder from CVS (which Hudson used to do for us, 
# but apparently it can do initial fetch from only one SCM. 

# make this listing, so we get layout logged
ls -lA --classify --group-directories-first


/shared/common/jdk-1.6.x86_64/bin/java -Xmx500m -jar $relengBaseBuilderDir/plugins/org.eclipse.equinox.launcher.jar -DWORKSPACE=$WORKSPACE  -DbuildId=$buildId -DBUILD_WORKSPACE=$BUILD_WORKSPACE -DBUILD_JOB_NAME=$BUILD_JOB_NAME -DBUILD_BUILD_NUMBER=$BUILD_BUILD_NUMBER -DBUILD_ID=$BUILD_ID -Dosgi.os=linux -Dosgi.ws=gtk -Dosgi.arch=x86_64 -Dhudson=true -Dcurrentbuildrepo=$currentbuildrepo -Djava.home=$JAVA_HOME -application org.eclipse.ant.core.antRunner -v -f $eclipseBuilderDir/testScripts/runTests2.xml
