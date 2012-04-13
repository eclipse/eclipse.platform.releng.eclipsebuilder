# general purpose utility for "hard exit" is return code not zero. 
# especially useful to call/check after basic things that should normally 
# easily succeeed. 
# usage: 
#   checkForErrorExit $? "Failed to copy file (for example)" 
checkForErrorExit () {
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


# get the base builder (still in cvs)
updateBaseBuilder () {

    echo "[start] [`date +%H\:%M\:%S`] getting org.eclipse.releng.basebuilder using tag (or branch): ${basebuilderBranch}"

    if [ -d "${supportDir}" ]
    then
        cd "${supportDir}"
        echo "   changed current directory to ${PWD}"
    else
        echo "   ERROR: support directory did not exist as expected."  
        exit 1
    fi 


    if [ -d ${relengBaseBuilderDir} ]
    then
        echo "removing previous version of base builder, to be sure it is fresh, to see if related to to see if fixes bug 375780"
        rm -fr ${VERBOSE_REMOVES} ${relengBaseBuilderDir}
    fi

    if [[ ! -d "${relengBaseBuilderDir}" ]] 
    then
        #    echo "making directory: ${relengBaseBuilderDir}"
        #mkdir -p "${relengBaseBuilderDir}"
        #echo "DEBUG: creating cmd"
        # TODO: for some reason I could not get this "in" an executable command ... not enough quotes, or something? 
        #cmd="cvs -d :pserver:anonymous@dev.eclipse.org:/cvsroot/eclipse ${quietCVS} ex -r ${basebuilderBranch} -d org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder"
        # cvs -d :pserver:anonymous@dev.eclipse.org:/cvsroot/eclipse ${quietCVS} ex -r ${basebuilderBranch} -d org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder
        # TODO: make cvs user/protocol/host variables so can be rrun remotely also
        cvs -d :local:/cvsroot/eclipse ${quietCVS} ex -r ${basebuilderBranch} -d org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder
        checkForErrorExit $? "Could not check out basebuilder"
        #echo "cvs export cmd: ${cmd}"
        #"${cmd}"
    else
        echo "base builder already existed, so taking as accurate. Remember to delete it when fresh version needed."
    fi

}


updateEclipseBuilder() {

    echo "[`date +%H\:%M\:%S`] get ${eclipsebuilder} using tag or branch: ${eclipsebuilderBranch}"

    # get fresh script. This is one case, we must get directly from repo since the purpose of the script 
    # is to get the eclipsebuilder! 
    wget -O getEclipseBuilder.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/getEclipseBuilder.sh?h=master
    chmod +x getEclipseBuilder.sh 

    # execute (in current directory) ... depends on some "exported" properties. 
    ./getEclipseBuilder.sh

    checkForErrorExit $? "Failed to get the Eclipse Buidler"
}


runSDKBuild () 
{

    echo "Starting runSDKBuild"
    echo "[start] [`date +%H\:%M\:%S`] setting eclipse ${eclipsestream}-I-Builds"
    echo "DEBUG: current directory: ${PWD}"

    if [ -d "${supportDir}" ]
    then
        cd $supportDir
        echo "Changed to directory ${PWD}"
    else
        echo "Cound not cd to ${supportDir}"
        exit 1
    fi

    echo "DEBUG: current directory for build: ${PWD}" 

    # TODO: should remove buildType (and others) and/or fail if not defined yet.
    buildType=I
    buildId=$buildType$date-$time
    buildLabel=$buildId
    buildfile=$supportDir/$eclipsebuilder/buildAll.xml
    mapVersionTag=R4_HEAD
    bootclasspath="/shared/common/j2sdk1.4.2_19/jre/lib/rt.jar:/shared/common/j2sdk1.4.2_19/jre/lib/jsse.jar:/shared/common/j2sdk1.4.2_19/jre/lib/jce.jar"
    bootclasspath_15="/shared/common/jdk-1.5.0_16/jre/lib/rt.jar:/shared/common/jdk-1.5.0_16/jre/lib/jsse.jar:/shared/common/jdk-1.5.0_16/jre/lib/jce.jar"
    bootclasspath_16="/shared/common/jdk1.6.0_27.x86_64/jre/lib/rt.jar:/shared/common/jdk1.6.0_27.x86_64/jre/lib/jsse.jar:/shared/common/jdk1.6.0_27.x86_64/jre/lib/jce.jar"
    bootclasspath_foundation="/shared/common/org.eclipse.sdk-feature2/libs/ee.foundation-1.0.jar"
    bootclasspath_foundation11="/shared/common/org.eclipse.sdk-feature2/libs/ee.foundation.jar"
    # https://bugs.eclipse.org/bugs/show_bug.cgi?id=375976, and 
    # https://bugs.eclipse.org/bugs/show_bug.cgi?id=376029
    OSGiMinimum11="/shared/common/org.eclipse.sdk-feature2/libs/ee.minimum.jar"
    OSGiMinimum12="/shared/common/org.eclipse.sdk-feature2/libs/ee.minimum-1.2.0.jar"

    javadoc="-Djavadoc16=/shared/common/jdk1.6.0_27.x86_64/bin/javadoc"

    skipPerf="-Dskip.performance.tests=true"
    skipTest="-Dskip.tests=true"

    # 'sign' works by setting as anything if desire signing, 
    # else, comment out. Comment out now to save time. 
    sign="-Dsign=true"

    # The cpAndMain is used to launch antrunner app (instead of using eclipse executable
    cpLaunch=$( find $relengBaseBuilderDir/plugins -name "org.eclipse.equinox.launcher_*.jar" | sort | head -1 )
    cpAndMain="$cpLaunch org.eclipse.equinox.launcher.Main"
    echo "DEBUG: cpLaunch: ${cpLaunch}"
    echo "DEBUG: cpAndMain: ${cpAndMain}"


    # hudson is an indicator of running on build.eclipse.org
    hudson="-Dhudson=true"

    echo "DEBUG: in runSDKBuild buildfile: $buildfile"

    # NOTE: the builder (or, some part if it) appears to 
    # REQUIRE Java 1.6, but its not obivous
    # See bug https://bugs.eclipse.org/bugs/show_bug.cgi?id=375807#c50 
    #
    # Remember that setting -debug will turn on debug for ant, which produces 
    # WAY too much output.    
    cmd="${JAVA_HOME}/bin/java -Xmx1000m -enableassertions \
    -cp $cpAndMain \
    -data $buildRoot/workspace-eclipse4 \
    -application org.eclipse.ant.core.antRunner  \
    -buildfile $buildfile \
    -DbuildType=$buildType \
    -DeclipseStream=$eclipseStream \
    -Dbuilddate=$date \
    -Dbuildtime=$time \
    -DbuildId=$buildId \
    -Dbuildid=$buildId \
    -DbuildLabel=$buildLabel \
    -Dbase=$buildDir \
    -DmapVersionTag=$mapVersionTag \
    -Dorg.eclipse.update.jarprocessor.pack200=${pack200dir} \
    -Declipse.p2.MD5Check=false \
    $skipPerf \
    $skipTest \
    $hudson \
    -DJ2SE-1.5=$bootclasspath_15 \
    -DJ2SE-1.4=$bootclasspath \
    -DCDC-1.0/Foundation-1.0=$bootclasspath_foundation \
    -DCDC-1.1/Foundation-1.1=$bootclasspath_foundation11 \
    -DOSGi/Minimum-1.0=$OSGiMinimum11 \
    -DOSGi/Minimum-1.1=$OSGiMinimum11 \
    -DOSGi/Minimum-1.2=$OSGiMinimum12 \
    -DJavaSE-1.6=$bootclasspath_16 \
    -DlogExtension=.xml \
    $javadoc \
    $sign \
    $repoCache \
    -DgenerateFeatureVersionSuffix=true \
    -Djava15home=${java15home} \
    -DupdateSite=${localUpdateSite} \
    -DpostingDirectory=$postingDirectory \
    -DequinoxPostingDirectory=$equinoxPostingDirectory"


    echo "INFO: save copy of command, to enable restarting into ${supportDir}/${eclipsebuilder}/command.txt"
    echo $cmd > $supportDir/$eclipsebuilder/command.txt
    # echo cmd to log/console
    echo "cmd: $cmd"
    # finally, start the java job
    $cmd  

}



tagRepo () {
    echo "DEBUG: starting tagRepo"
    pushd ${PWD}
    # we assume we already got the eclipsebuilder successfully
    # and we use the "working" version copied from gitClones
    releasescriptpath=$builderDir/scripts

    echo "DEBUG: using script in ${releasescriptpath}/git-release.sh"
    # remember, -committerId "$committerId" not required on build.eclipse.org
    # will need to do more if/when we make it a variable property (such as for 
    # committers running remotely, or even non-committers runnning remotely.
    #
    tagRepocmd="/bin/bash ${releasescriptpath}/git-release.sh -relengBranch $relengBranch \
    -relengMapsProject $relengMapsProject \
    -relengRepoName $relengRepoName \
    -buildType $buildType \
    -gitCache $gitCache \
    -buildRoot $buildRoot \
    -gitEmail \"$gitEmail\" -gitName \"$gitName\" \
    -timestamp $timestamp -oldBuildTag $oldBuildTag -buildTag $buildTag \
    -submissionReportFilePath $submissionReportFilePath \
    -tag $tag "

    echo "tag repo command: $tagRepocmd" 

    $tagRepocmd

    exitCode=$?
    echo
    echo "   ERROR. Autotagging exit code: ${exitCode} "
    echo
    return $exitCode
}


