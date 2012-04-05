#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2012 IBM Corporation and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#     IBM Corporation - initial API and implementation
#*******************************************************************************


#default values, overridden by command line
writableBuildRoot=/shared/eclipse/eclipse4
mkdir -p "${writableBuildRoot}"
export buildDir=$writableBuildRoot/build
mkdir -p "${buildDir}"

relengMapsProject=org.eclipse.releng
relengRepoName=eclipse.platform.releng.maps

# This is eclipsebuilder name on disk, traditionally org.eclipse.releng.eclipsebuilder
# Though now in git, the repo (and effective project name) is eclipse.platform.releng.eclipsebuilder 
# See https://bugs.eclipse.org/bugs/show_bug.cgi?id=374974 for details, 
# especially https://bugs.eclipse.org/bugs/show_bug.cgi?id=374974#c28
export eclipsebuilder=org.eclipse.releng.eclipsebuilder
export eclipsebuilderRepo=eclipse.platform.releng.eclipsebuilder

relengBranch=R4_HEAD
buildType=I
date=$(date +%Y%m%d)
time=$(date +%H%M)
timestamp=$date$time
#TODO: make committerId a better property.  I think only used (now) 
# to push things to "downloads" site.
committerId=pwebster
export gitEmail=e4Build
export gitName=e4Builder-R4

tag=false
publish=false

eclipseStream=4.2
basebuilderBranch=R4_2_primary
export eclipsebuilderBranch=R4_2_primary

# common properties

javaHome=/shared/common/sun-jdk1.6.0_21_x64
buildTimestamp=${date}-${time}
buildTag=$buildType$buildTimestamp



# DEBUG controls verbosity of little "state and status" bash echo messages.
# Set to true to get the most echo messages. Anything else to be quiet. 
# Normally would be false during production, but true for debugging/tests. 
export DEBUG=${DEBUG:-false}
#export DEBUG=${DEBUG:-true}
echo "DEBUG: $DEBUG"

# VERBOSE_REMOVES needs to be empty or literally '-v', since
# simply makes up part of "rm" command when directories or files removed.
# normally empty for production runs, but might help in debugging.
# (but, it is VERY verbose)
export VERBOSE_REMOVES=${VERBOSE_REMOVES:-}
#export VERBOSE_REMOVES=${VERBOSE_REMOVES:--v}
echo "VERBOSE_REMOVES: $VERBOSE_REMOVES"

# quietCVS needs to be -Q (really quiet) -q (somewhat quiet) or literally empty (verbose)
# FYI, not that much difference between -Q and -q :) 
# TODO: won't be needed once move off CVS is complete
export quietCVS=${quietCVS:--Q}
#export quietCVS=${quietCVS:--q}
#export quietCVS=${quietCVS:-}



arch="x86_64"
archProp="-x86_64"
archJavaProp=""
processor=$( uname -p )
if [ $processor = ppc -o $processor = ppc64 ]; then
    archProp="-ppc"
    archJavaProp="-DarchProp=-ppc"
    arch="ppc"
fi

#
#  control various aspects of the build
#


while [ $# -gt 0 ]
do
    case "$1" in
        "-relengBranch")
            relengBranch="$2"; shift;;
        "-eclipseStream")
            eclipseStream="$2"; shift;;
        "-buildType")
            buildType="$2"; shift;;
        "-gitCache")
            gitCache="$2"; shift;;
        "-relengMapsProject")
            relengMapsProject="$2"; shift;;
        "-relengRepoName")
            relengRepoName="$2"; shift;;  
        "-root")
            writableBuildRoot="$2"; shift;;
        "-committerId")
            committerId="$2"; shift;;
        "-gitEmail")
            gitEmail="$2"; shift;;
        "-gitName")
            gitName="$2"; shift;;
        "-basebuilderBranch")
            basebuilderBranch="$2"; shift;;
        "-eclipsebuilderBranch")
            eclipsebuilderBranch="$2"; shift;;
        "-timestamp")
            timestamp="$2";
            date=${timestamp:0:8}
            time=${timestamp:8};
            shift;;
        *) break;;      # terminate while loop
    esac
    shift
done

export supportDir=${buildDir}/supportDir
mkdir -p "${supportDir}"

if [ -z "$gitCache" ]; then
    export gitCache=$supportDir/gitCache
    # ensure exists, in case not
    mkdir -p $gitCache
    echo "INFO: value of gitCache: ${gitCache}"
else
    echo "WARNING: unexpected value of gitCache already defined: ${gitCache}"
fi

export builderDir=${supportDir}/$eclipsebuilder
# remember: do not "mkdir" for builderDir since presence/absence 
# might be used later to determine if fresh check out needed or not.
# mkdir -p "${builderDir}"
echo "INFO: value of builderDir: ${builderDir}"

if [ "$buildType" = "N" ]; then
    echo "DEBUG: tag forced to false due to being an N build"
    tag=false
fi

#publish
# TODO: make variable to use file system directly when running on build.eclipse.org
# TODO: will need to test with some "safe" locations first.
publishIndex="${committerId}@build.eclipse.org:/home/data/httpd/download.eclipse.org/eclipse/downloads"
publishSDKIndex="${committerId}@build.eclipse.org:/home/data/httpd/download.eclipse.org/eclipse/downloads"
publishUpdates="${committerId}@build.eclipse.org:/home/data/httpd/download.eclipse.org/eclipse/updates"
publishDir="${publishIndex}/drops4"




if [ -f $writableBuildRoot/${buildType}build.properties ]
then
    oldBuildTag=$( cat $writableBuildRoot/${buildType}build.properties )
else
    oldBuildTag="NONE"
fi
echo "Last build: $oldBuildTag"
echo $buildTag >$writableBuildRoot/${buildType}build.properties
dropDir=4.2.0
localDropDirectory=${buildDir}/downloads/drops/$dropDir
mkdir -p $localDropDirectory
buildResults=$localDropDirectory/$buildTag
mkdir -p $buildResults
submissionReportFilePath=$buildResults/report.txt


# these don't seem right (not sure what they are)?
# currently ends up being 
# .../eclipse4/build/40builds/targets
# and contains the ?local repo? (not runnable) for org.eclipse.emf.common, etc.
# in directories named, for example,
# as .../eclipse4/build/40builds/targets/local-repo-I20120331-0050
targetDir=${buildDir}/targets
targetZips=${targetDir}/targetzips

# should not set globally to java via -Dproperty=value, since eclipsebuilder 
# assumes different scopes and changes this value for direct calls to generatescripts
transformedRepo=${targetDir}/transformedRepo

# should not set globally to java via -Dproperty=value, since eclipsebuilder 
# assumes different scopes and changes this value for direct calls to generatescripts
buildDirectory=${buildDir}/$buildTag

#rembember, don't point to e4Build user directory
sdkTestDir=${writableBuildRoot}/sdkTests/$buildTag

sdkResults=$buildDir/40builds/$buildTag/$buildTag
sdkBuildDirectory=$buildDir/40builds/$buildTag

relengBaseBuilderDir=$supportDir/org.eclipse.releng.basebuilder
buildDirEclipse="$buildDir/eclipse"
WORKSPACE="$buildDir/workspace"
export WORKSPACE

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


# first, let's check out all of those pesky projects
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

    echo "DEBUG: checking existence"
    
    if [[ -d "${relengBaseBuilderDir}" ]]
     then
           echo "removing previous version of base builder, to be sure it is fresh, to see if related to to see if fixes bug 375780"
           rm -fr ${VERBOSE_REMOVES} "${relengBaseBuilderDir}"
     fi

    if [[ ! -d "${relengBaseBuilderDir}" ]] 
    then
        #    echo "making directory: ${relengBaseBuilderDir}"
        #mkdir -p "${relengBaseBuilderDir}"
        #echo "DEBUG: creating cmd"
        #cmd="cvs -d :pserver:anonymous@dev.eclipse.org:/cvsroot/eclipse ${quietCVS} ex -r ${basebuilderBranch} -d org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder"
        cvs -d :pserver:anonymous@dev.eclipse.org:/cvsroot/eclipse ${quietCVS} ex -r ${basebuilderBranch} -d org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder
        #echo "cvs export cmd: ${cmd}"
        #"${cmd}"
    else
        echo "base builder already existed, so taking as accurate. Remember to delete it when fresh version needed."
    fi

}

updateBaseBuilderInfo() {
    #TODO: there should be ways to avoid computing these at this point? 
    # now update the variables that depend on this
    #pdeDir=$( find $relengBaseBuilderDir/ -name "org.eclipse.pde.build_*" | sort | head -1 )
    #buildfile=$pdeDir/scripts/build.xml
    
    # The cpAndMain is used to launch antrunner app (instead of using eclipse executable
    cpLaunch=$( find $relengBaseBuilderDir/plugins -name "org.eclipse.equinox.launcher_*.jar" | sort | head -1 )
    cpAndMain="$cpLaunch org.eclipse.equinox.launcher.Main"
    #echo "DEBUG: pdeDir: ${pdeDir}"
    # TODO: we do not use this buildfile, but reset it to "buildAll.xml" in runSDKBuild
    # hence, in this case, no need for it, nor the pdeDir (which the 'find' seems to take a while)
    #echo "DEBUG: buildfile: ${buildfile}"
    echo "DEBUG: cpLaunch: ${cpLaunch}"
    echo "DEBUG: cpAndMain: ${cpAndMain}"
}


updateEclipseBuilder() {

    echo "[`date +%H\:%M\:%S`] cvs get ${eclipsebuilder} using tag or branch: ${eclipsebuilderBranch}"

    # TODO: I do not think we need to "cd" to supportDir here
    #if [ -d $supportDir ]
    #then
        #    cd $supportDir
        #echo "   changed current directory to ${supportDir}"
    # else
        #    echo "   ERROR: support directory did not exist as expected."  
        #exit 1
    #fi 

     # get fresh script. This is one case, we must get directly from repo since the purpose of the script 
     # is to get the eclipsebuilder! 
    wget -O getEclipseBuilder.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/getEclipseBuilder.sh?h=R4_2_primary
    chmod +x getEclipseBuilder.sh 
    
    # execute (in current directory) ... depends on some "exported" properties. 
    ./getEclipseBuilder.sh
    
    checkForErrorExit $? "Failed to get the Eclipse Buidler"
}

sync_sdk_repo_updates () {
    # TODO: change to file protocols for build.eclipse.org
    fromDir=$targetDir/updates/${eclipseStream}-I-builds
    toDir="${committerId}@build.eclipse.org:/home/data/httpd/download.eclipse.org/eclipse/updates"

    rsync --recursive --delete "${fromDir}" "${toDir}"
}

runSDKBuild () {

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
    
    # should skipPack to save time
    # TODO: I do not think we ever need to "pack" if we do not "sign"
    # and if we sign, signing does it automatically. 
    # skipPack="-DskipPack=true"
    
    # 'sign' works by setting as anything if desire signing, 
    # else, comment out. 
    #sign="-Dsign=true"
    
    # test tagMaps for autotagging, else, comment out. 
    # note: running an N build will override this setting 
    # (that is, N builds will not tag the maps, even if specify tagMaps=true.
    tagMaps="-DtagMaps=true"
    
    #TODO: assume this would eventually be downloads? Or is it a temporary location, on 
    # build machine, which is later copied over to downloads? 
    postingDirectory=$supportDir
    
    # hudson is an indicator of running on build.eclipse.org
    hudson="-Dhudson=true"

    echo "DEBUG: in runSDKBuild buildfile:$buildfile"

    cmd="$javaHome/bin/java -Xmx1000m -enableassertions \
        -cp $cpAndMain \
        -application org.eclipse.ant.core.antRunner  \
        -buildfile $buildfile \
        -DbuildType=$buildType \
        -Dbuilddate=$date \
        -Dbuildtime=$time \
        -DbuildId=$buildId \
        -Dbuildid=$buildId \
        -DbuildLabel=$buildLabel \
        -Dbase=$buildDir/40builds \
        -DupdateSite=$supportDir/updates/4.2-I-builds \
        -DmapVersionTag=$mapVersionTag \
        -Dorg.eclipse.update.jarprocessor.pack200=$javaHome \
        -Declipse.p2.MD5Check=false \
        $skipPerf \
        $skipTest \
        $skipPack \
        $skipSourceBuild \
        $tagMaps \
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
        -Djava15home=${javaHome} \
        -DpostingDirectory=$postingDirectory"


    echo "INFO: save copy of command, to enable restarting into ${supportDir}/${eclipsebuilder}/command.txt"
    echo $cmd > $supportDir/$eclipsebuilder/command.txt
    # echo cmd to log/console
    echo "cmd: $cmd"
    # finally, start the java job
    $cmd  

    #stop now if the build failed
    #failure=$(sed -n '/BUILD FAILED/,/Total time/p' $writableBuildRoot/logs/current.log)
    #if [[ ! -z $failure ]]; then
    #	compileMsg=""
    #	prereqMsg=""
    #	pushd $sdkBuildDirectory/plugins
    #	compileProblems=$( find . -name compilation.problem | cut -d/ -f2 )
    #	popd
    #	
    #	if [[ ! -z $compileProblems ]]; then
    #		compileMsg="Compile errors occurred in the following bundles:"
    #	fi
    #	if [[ -e $buildDirectory/prereqErrors.log ]]; then
    #		prereqMsg=`cat $buildDirectory/prereqErrors.log` 
    #	fi
    #	
    #	mailx -s "$eclipseStream SDK Build: $buildTag failed" platform-releng-dev@eclipse.org e4-dev@eclipse.org <<EOF
    #$compileMsg
    #$compileProblems

    #$prereqMsg

    #$failure
    #EOF
    #		exit
    #	fi 
    #      
    #	sync_sdk_repo_updates
}

process_build () {
    buildId=$1 ; shift
    echo "Processing $BASE_DIR/$buildId/$buildId"

    if [ -e $BASE_DIR/$buildId ]; then
        return;
    fi

    mkdir -p $BASE_DIR/$buildId

    cd $TMPL_DIR
    cp *.php *.htm*  *.gif *.jpg  $BASE_DIR/$buildId

    cd $HUDSON_DROPS/$buildId/$buildId

    cp *.htm*  $BASE_DIR/$buildId
    cp -r results $BASE_DIR/$buildId

    ZIPS=$( echo $ORIG_ZIPS | sed "s/ReplaceMe/$buildId/g" )
    for f in $ZIPS; do
        echo $f
        cp $f  $BASE_DIR/$buildId
    done

    cp -fr *repository.zip buildlogs checksum compilelogs $BASE_DIR/$buildId
    #cp -r $HUDSON_REPO/$buildId  $BASE_DIR/$buildId/repository

    cp  $TMPL_DIR/download.php  $BASE_DIR/$buildId

    for f in $( echo $FILES_TO_UPDATE ); do
        cat $TMPL_DIR/$f | sed "s/ReplaceMe/$buildId/g" >$BASE_DIR/$buildId/$f
    done

    scp -r $BASE_DIR/$buildId ${committerId}@build.eclipse.org:/home/data/httpd/download.eclipse.org/eclipse/downloads/drops4


    echo Done $buildId

    failed=""
    testsMsg=$(sed -n '/<!--START-TESTS-->/,/<!--END-TESTS-->/p' $HUDSON_DROPS/$buildId/$buildId/results/testResults.html > mail.txt)
    testsMsg=$(cat mail.txt | sed s_href=\"_href=\"http://download.eclipse.org/eclipse/downloads/drops4/$buildId/results/_)
    rm ${VERBOSE_REMOVES} mail.txt

    red=$(echo $testsMsg | grep "color:red")
    if [[ ! -z $red ]]; then
        failed="tests failed"
    fi

    (
    echo "From: e4Build@build.eclipse.org "
    echo "To: platform-releng-dev@eclipse.org "
    echo "MIME-Version: 1.0 "
    echo "Content-Type: text/html; charset=us-ascii"
    echo "Subject: $eclipseStream SDK Build: $buildId $failed"
    echo ""
    echo "<html><head><title>$eclipseStream SDK Build $buildId</title></head>" 
    echo "<body>Check here for the build results: <a href=\"http://download.eclipse.org/eclipse/downloads/drops4/$buildId\">$buildId</a><br>" 
    echo "$testsMsg</body></html>" 
    ) | /usr/lib/sendmail -t

}

publish_sdk () {

    BASE_DIR=${writableBuildRoot}/sdk
    TMPL_DIR=$BASE_DIR/template

    ORIG_ZIPS="
    eclipse-SDK-ReplaceMe-linux-gtk-ppc64.tar.gz
    eclipse-SDK-ReplaceMe-linux-gtk.tar.gz
    eclipse-SDK-ReplaceMe-linux-gtk-x86_64.tar.gz
    eclipse-SDK-ReplaceMe-macosx-cocoa.tar.gz
    eclipse-SDK-ReplaceMe-macosx-cocoa-x86_64.tar.gz
    eclipse-SDK-ReplaceMe-win32-x86_64.zip
    eclipse-SDK-ReplaceMe-win32.zip
    eclipse-SDK-ReplaceMe-aix-gtk-ppc.zip
    eclipse-SDK-ReplaceMe-aix-gtk-ppc64.zip
    eclipse-SDK-ReplaceMe-hpux-gtk-ia64_32.zip
    eclipse-SDK-ReplaceMe-solaris-gtk.zip
    eclipse-SDK-ReplaceMe-solaris-gtk-x86.zip
    "

    FILES_TO_UPDATE="
    linPlatform.php
    macPlatform.php
    sourceBuilds.php
    winPlatform.php
    index.php
    "

    HUDSON_COMMON=${writableBuildRoot}/build/downloads/drops/$dropDir/40builds
    HUDSON_DROPS=$HUDSON_COMMON
    HUDSON_REPO=$targetDir/updates/${eclipseStream}-I-builds



    # find the builds to process

    BUILDS=$( ls -d $HUDSON_DROPS/${buildType}* | cut -d/ -f11 )

    if [ -z "$BUILDS" -o  "$BUILDS" = "${buildType}*" ]; then
        return
    fi

    for f in $BUILDS; do
        process_build $f
    done

    cd $TMPL_DIR


    #Temporarily do not update index.htmLd
    #wget -O index.txt http://download.eclipse.org/eclipse/downloads/createIndex4x.php
    #scp index.txt ${committerId}@build.eclipse.org:/home/data/httpd/download.eclipse.org/eclipse/downloads/index.html
}

runSDKTests() {
    mkdir -p $sdkTestDir
    cd $sdkTestDir

    echo "Copying eclipse SDK archive to tests." 
    cp $sdkResults/eclipse-SDK-*-linux-gtk${archProp}.tar.gz  .

    cat $sdkBuildDirectory/test.properties >> test.properties
    cat $sdkBuildDirectory/label.properties >> label.properties

    echo "sdkResults=$sdkResults" >> label.properties
    echo "e4Results=$buildResults" >> label.properties
    echo "buildType=$buildType" >> label.properties
    echo "sdkRepositoryRoot=$targetDir/updates/${eclipseStream}-I-builds" >> label.properties

    echo "Copying test framework."
    cp -r ${builderDir}/builder/general/tests/* .

    ./runtests -os linux -ws gtk -arch ${arch} sdk

    mkdir -p $sdkResults/results
    cp -r results/* $sdkResults/results

    cd $sdkBuildDirectory
    mv $sdkTestDir $sdkBuildDirectory/eclipse-testing

    publish_sdk
}

copyCompileLogs () {
    pushd $buildResults
    cat >${buildResults}/compilelogs.html <<EOF
    <html><head><title>compile logs</title></head>
    <body>
    <h1>compile logs</h1>
    <table border="1">
EOF

    for f in $( find compilelogs -name "*.html" ); do
        FN=$( basename $f )
        FN_DIR=$( dirname $f )
        PA_FN=$( basename $FN_DIR )
        cat >>$buildResults/compilelogs.html <<EOF
        <tr><td><a href="$f">$PA_FN - $FN</a></td></tr>
EOF

    done
    cat >>$buildResults/compilelogs.html <<EOF
    </table>
    </body>
    </html>

EOF

    popd

}

generateRepoHtml () {
    pushd $buildResults/repository

    cat >$buildResults/repository/index.html <<EOF
    <html><head><title>Eclipse4 p2 repo</title></head>
    <body>
    <h1>E4 p2 repo</h1>
    <table border="1">
    <tr><th>Feature</th><th>Version</th></tr>

EOF

    for f in features/*.jar; do
        FN=$( basename $f .jar )
        FID=$( echo $FN | cut -f1 -d_ )
        FVER=$( echo $FN | cut -f2 -d_ )
        echo "<tr><td>$FID</td><td>$FVER</td></tr>" >> $buildResults/repository/index.html
    done

    cat >>$buildResults/repository/index.html <<EOF
    </table>
    </body>
    </html>

EOF

    popd

}



runTheTests () {
    mkdir -p $e4TestDir
    cd $e4TestDir

    echo "Copying eclipse SDK archive to tests." 
    cp $sdkResults/eclipse-SDK-*-linux-gtk${archProp}.tar.gz  .

    cat $buildDirectory/test.properties >> test.properties
    cat $buildDirectory/label.properties >> label.properties

    echo "sdkResults=$sdkResults" >> label.properties
    echo "e4Results=$buildResults" >> label.properties
    echo "buildType=$buildType" >> label.properties
    echo "sdkRepositoryRoot=$targetDir/updates/${eclipseStream}-I-builds" >> label.properties

    echo "Copying test framework."
    cp -r ${builderDir}/builder/general/tests/* .

    ./runtests -os linux -ws gtk \
        -arch ${arch}  $1

    mkdir -p $buildResults/results
    cp -r results/* $buildResults/results

    cd $buildDirectory
    mv $e4TestDir $buildDirectory/eclipse-testing

    cp ${builderDir}/templates/build.testResults.html \
        $buildResults/testResults.html

}

sendMail () {
    failed=""
    testsMsg=$(sed -n '/<!--START-TESTS-->/,/<!--END-TESTS-->/p' $buildResults/results/testResults.html > mail.txt)
    testsMsg=$(cat mail.txt | sed s_href=\"_href=\"http://download.eclipse.org/eclipse/downloads/drops/$buildTag/results/_)
    rm mail.txt

    red=$(echo $testsMsg | grep "color:red")
    if [[ ! -z $red ]]; then
        failed="tests failed"
    fi

    # test value, initially
    toAddress=david_williams@us.ibm.com
    #toAddress=platform-releng-dev@eclipse.org

    (
    echo "From: e4Build@build.eclipse.org "
    echo "To: ${toAddress} "
    echo "MIME-Version: 1.0 "
    echo "Content-Type: text/html; charset=us-ascii"
    echo "Subject: $eclipseStream Build: $buildTag $failed"
    echo " "
    echo "<html><head><title>$eclipseStream Build: $buildTag $failed</title></head>" 
    echo "<body>Check here for the build results: <a href=\"http://download.eclipse.org/eclipse/downloads/dropsd/${buildTag}\">${buildTag}</a><br><br>" 
    echo "$testsMsg</body></html>" 
    ) | /usr/lib/sendmail -t

}


swtExport () {
    swtMap=$buildDirectory/maps/e4/releng/org.eclipse.e4.swt.releng/maps/swt.map
    swtName=$1
    swtVer=$( grep ${swtName}= $swtMap | cut -f1 -d, | cut -f2 -d= )
    swtPlugin=$( grep ${swtName}= $swtMap | cut -f4 -d, )
    if [ -z "$swtPlugin" ]; then
        swtPlugin=$swtName
    fi

    cmd="cvs -d :pserver:anonymous@dev.eclipse.org:/cvsroot/eclipse $quietCVS ex -r $swtVer -d $swtName $swtPlugin"
    echo $cmd
    $cmd
}

generateSwtZip () {
    mkdir -p $buildDirectory/swt
    cd $buildDirectory/swt
    swtExport org.eclipse.swt
    ls -d org.eclipse.swt/Ecli*/* | grep -v common | grep -v emulate | while read line; do rm -rf "$line" ; done
    cp org.eclipse.swt/.classpath_flex org.eclipse.swt/.classpath
    rm -rf org.eclipse.swt/build
    swtExport org.eclipse.swt.e4
    cp -r org.eclipse.swt.e4/* org.eclipse.swt
    awk ' /<linkedResources/,/<\/linkedResource/ {next } { print $0 } ' org.eclipse.swt/.project >tmp.txt
    cp tmp.txt org.eclipse.swt/.project
    grep -v org.eclipse.swt.awt org.eclipse.swt/META-INF/MANIFEST.MF >tmp.txt
    cp tmp.txt org.eclipse.swt/META-INF/MANIFEST.MF
    swtExport org.eclipse.swt.e4.jcl
    cp org.eclipse.swt.e4.jcl/.classpath_flex org.eclipse.swt.e4.jcl/.classpath
    zip -r ../$buildTag/org.eclipse.swt.e4.flex-incubation-$buildTag.zip org.eclipse.swt org.eclipse.swt.e4.jcl
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
    # temp oldBuildTag, to go from "last known 4.2 I build", for now
    # but eventually will use 'oldBuildTag' as computed from previous I build.
    tempOldBuildTag="I20120321-0610"
    tagRepocmd="/bin/bash ${releasescriptpath}/git-release.sh -relengBranch $relengBranch \
        -relengMapsProject $relengMapsProject \
        -relengRepoName $relengRepoName \
        -buildType $buildType \
        -gitCache $gitCache \
        -root $writableBuildRoot \
        -gitEmail \"$gitEmail\" -gitName \"$gitName\" \
        -timestamp $timestamp -oldBuildTag $tempOldBuildTag -buildTag $buildTag \
        -submissionReportFilePath $submissionReportFilePath \
        -tag $tag "

    echo "tag repo command: $tagRepocmd" 

    $tagRepocmd

    popd
    mailx -s "$eclipseStream SDK Build: $buildTag submission" david_williams@us.ibm.com <$submissionReportFilePath
    #mailx -s "$eclipseStream SDK Build: $buildTag submission" platform-releng-dev@eclipse.org <$submissionReportFilePath
      echo "DEBUG: ending tagRepo"
}

updateBaseBuilder
updateBaseBuilderInfo

updateEclipseBuilder
checkForErrorExit $? "Failed while updating Eclipse Buidler"

#tagRepo

runSDKBuild
checkForErrorExit $? "Failed while building Eclipse-SDK"

# copy some other logs
#copyCompileLogs
#generateRepoHtml

# generate the SWT zip file
#generateSwtZip

# try some tests
#runSDKTests
#runTheTests e4less

#cp $writableBuildRoot/logs/current.log \
    #	$writableBuildRoot/$buildTag/report.txt \
    #    $buildResults/buildlog.txt


#if $publish && [ ! -z "$publishDir"  ]; then
#    echo Publishing  $buildResults to "$publishDir"
#    scp -r $buildResults "$publishDir"
#    rsync --recursive --delete ${targetDir}/updates/${e4Stream}-I-builds \
    #      "${publishUpdates}"
#    sendMail
#    sleep 60
#    wget -O index.txt http://download.eclipse.org/e4/downloads/createIndex.php
#    scp index.txt "$publishIndex"/index.html
#fi

