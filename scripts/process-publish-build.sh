#TODO: make committerId a better property.  I think only used (now) 
# to push things to "downloads" site.
committerId=pwebster

publish=false

#publish
# TODO: make variable to use file system directly when running on build.eclipse.org
# TODO: will need to test with some "safe" locations first.
publishIndex="${committerId}@build.eclipse.org:/home/data/httpd/download.eclipse.org/eclipse/downloads"
publishSDKIndex="${committerId}@build.eclipse.org:/home/data/httpd/download.eclipse.org/eclipse/downloads"
publishUpdates="${committerId}@build.eclipse.org:/home/data/httpd/download.eclipse.org/eclipse/updates"
publishDir="${publishIndex}/drops4"


sync_sdk_repo_updates () {
    # TODO: change to file protocols for build.eclipse.org
    fromDir=$targetDir/updates/${eclipseStream}-I-builds
    toDir="${committerId}@build.eclipse.org:/home/data/httpd/download.eclipse.org/eclipse/updates"

    rsync --recursive --delete "${fromDir}" "${toDir}"
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

publish_sdk () {

    BASE_DIR=${buildRoot}/sdk
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

    HUDSON_COMMON=${buildRoot}/build/downloads/drops/$dropDir/
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


# this used to be at the end of "runSDKBuild", 
    # 
    #stop now if the build failed
    #failure=$(sed -n '/BUILD FAILED/,/Total time/p' $buildRoot/logs/current.log)
    #if [[ ! -z $failure ]]; then
    #   compileMsg=""
    #   prereqMsg=""
    #   pushd $sdkBuildDirectory/plugins
    #   compileProblems=$( find . -name compilation.problem | cut -d/ -f2 )
    #   popd
    #   
    #   if [[ ! -z $compileProblems ]]; then
    #       compileMsg="Compile errors occurred in the following bundles:"
    #   fi
    #   if [[ -e $buildDirectory/prereqErrors.log ]]; then
    #       prereqMsg=`cat $buildDirectory/prereqErrors.log` 
    #   fi
    #   
    #   mailx -s "$eclipseStream SDK Build: $buildTag failed" platform-releng-dev@eclipse.org e4-dev@eclipse.org <<EOF
    #$compileMsg
    #$compileProblems

    #$prereqMsg

    #$failure
    #EOF
    #       exit
    #   fi 
    #      
    #   sync_sdk_repo_updates






# this used to be "conclusion" of masterBuild.sh, 
# coming right after the call call to runSDKBuild

# copy some other logs
#copyCompileLogs
#generateRepoHtml

# generate the SWT zip file
#generateSwtZip

# try some tests
#runSDKTests
#runTheTests e4less

#cp $buildRoot/logs/current.log \
    #   $buildRoot/$buildTag/report.txt \
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

