#!/usr/bin/env bash

# compute build machine drop directory
function dropDir()
{

    pathToDL=$( dlpath "$eclipseStream" "$buildId" "$BUILD_TECH" )

    if [[ "$pathToDL" == 1 ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: dlpath could not be computed."
        return 1
    fi

    eclipseStreamMajor=${eclipseStream:0:1}
    buildType=${buildId:0:1}

    if [[ "${BUILD_TECH}" == 'CBI' ]]
    then 
        buildRoot=/shared/eclipse/builds/${eclipseStreamMajor}${buildType}
    else
        buildRoot=/shared/eclipse/eclipse${eclipseStreamMajor}${buildType}
    fi

    siteDir=${buildRoot}/siteDir

    fromDir=${siteDir}/${pathToDL}/${buildId}
    if [[ ! -d "${fromDir}" ]]
    then
        echo "ERROR: fromDir is not a directory? fromDir: ${fromDir}"
        return 1
    else
        echo "$fromDir"
    fi
}

# compute main (left part) of download site
function dlpath()
{
    eclipseStream=$1
    if [[ -z "${eclipseStream}" ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: Must provide eclipseStream as first argumnet, for this function $(basename $0)"
        return 1;
    fi


    buildId=$2
    if [[ -z "${buildId}" ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: Must provide buildId as second argumnet, for this function $(basename $0)"
        return 1;
    fi

    BUILD_TECH=$3
    if [[ -z "${BUILD_TECH}" ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: Must provide BUILD_TECH as third argumnet, for this function $(basename $0)"
        return 1;
    fi



    eclipseStreamMajor=${eclipseStream:0:1}
    buildType=${buildId:0:1}

    #TODO: eventual switch so CBI is "normal" one and PDE is marked one
    if [[ "${BUILD_TECH}" == 'CBI' ]]
    then 
        dropsuffix=cbibased
    else
        dropsuffix=""
    fi

    pathToDL=eclipse/downloads/drops
    if [[ $eclipseStreamMajor > 3 ]]
    then
        pathToDL=$pathToDL$eclipseStreamMajor
    fi

    pathToDL=$pathToDL$dropsuffix

    echo $pathToDL
}

function sendPromoteMail ()
{
    # this buildeclipse.shsource file is to ease local builds to override some variables. 
    # It should not be used for production builds.
    source buildeclipse.shsource 2>/dev/null
    SITE_HOST=${SITE_HOST:-download.eclipse.org}

    echo "     Starting sendPromoteMail"
    eclipseStream=$1
    if [[ -z "${eclipseStream}" ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: Must provide eclipseStream as first argumnet, for this function $(basename $0)"
        return 1;
    fi
    echo "     eclipseStream: ${eclipseStream}"

    buildId=$2
    if [[ -z "${buildId}" ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: Must provide buildId as second argumnet, for this function $(basename $0)"
        return 1;
    fi
    echo "     buildId: ${buildId}"

    BUILD_TECH=$3
    if [[ -z "${BUILD_TECH}" ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: Must provide BUILD_TECH as third argumnet, for this function $(basename $0)"
        return 1;
    fi
    echo "     BUILD_TECH: ${BUILD_TECH}"

    eclipseStreamMajor=${eclipseStream:0:1}
    buildType=${buildId:0:1}
    echo "     buildType: ${buildType}"

    # ideally, the user executing this mail will have this special file in their home directory,
    # that can specify a custom 'from' variable, but still you must use your "real" ID that is subscribed
    # to the wtp-dev mailing list
    #   set from="\"Your Friendly WTP Builder\" <real-subscribed-id@real.address>"
    # correction ... doesn't work. Seems the subscription system set's the "from" name, so doesn't work when
    # sent to mail list (just other email addresses)
    # espeically handy if send from one id (e.g. "david_williams)
    export MAILRC=~/.e4Buildmailrc

    # common part of URL and file path
    # varies by build stream
    # examples of end result:
    # http://download.eclipse.org/eclipse/downloads/drops4/N20120415-2015/
    # /home/data/httpd/download.eclipse.org/eclipse/downloads/drops4/N20120415-2015


    mainPath=$( dlpath "$eclipseStream" "$buildId" "$BUILD_TECH" )
    echo "     mainPath: $mainPath"
    if [[ "$mainPath" == 1 ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: mainPath could not be computed."
        return 1
    fi

    downloadURL=http://${SITE_HOST}/${mainPath}/${buildId}/



    if [[ "${BUILD_TECH}" == "CBI" ]]
    then 
        # CBI based 4.2 Build: I20120411-2034
        SUBJECT="CBI based ${eclipseStream} ${buildType}-Build: ${buildId}"
    else
        # 4.2 Build: I20120411-2034
        SUBJECT="${eclipseStream} ${buildType}-Build: ${buildId}"
    fi



    TO="platform-releng-dev@eclipse.org"
    # for initial testing, only to me
    if [[ "${BUILD_TECH}" == "CBI" ]]
    then 
      TO="david_williams@us.ibm.com"
    fi

    # make sure reply to goes back to the list
    # I'm not positive this is required for mailing list?
    # does anything "from" list, automatically get reply-to: list?
    #REPLYTO="platform-releng-dev@eclipse.org"
    #we could? to "fix up" TODIR since it's in file form, not URL
    # URLTODIR=${TODIR##*${DOWNLOAD_ROOT}}


    mail -s "${SUBJECT}" "${TO}"  <<EOF

    Download:
    ${downloadURL}

    Software site repository:
    http://${SITE_HOST}/eclipse/updates/${eclipseStreamMajor}.${eclipseStreamMinor}-${buildType}-builds

EOF

    echo "mail sent for $eclipseStream $buildType-build $buildId"
    return 0
}


# start tests function
function startTests()
{
    echo "startTests()"
    eclipseStreamMajor=$1
    buildType=$2
    eclipseStream=$3
    buildId=$4
    BUILD_TECH=$5
    EBUILDER_HASH=$6
    if [[ -z "${EBUILDER_HASH}" ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: Must provide builder (or aggregator) hash as fourth argumnet, for this function $(basename $0)"
        return 1;
    fi

    echo "eclipseStreamMajor: $eclipseStreamMajor"
    echo "buildType: $buildType"
    echo "eclipseStream: $eclipseStream"
    echo "buildId: $buildId"
    echo "BUILD_TECH: $BUILD_TECH"
    echo "EBUILDER_HASH: $EBUILDER_HASH"
    if [[ "${BUILD_TECH}" == 'CBI' ]]
    then 
        buildRoot=/shared/eclipse/builds/${eclipseStreamMajor}${buildType}
        eclipsebuilder=eclipse.platform.releng.aggregator/production/testScripts
        dlPath=$( dlpath $eclipseStream $buildId $BUILD_TECH )
        echo "DEBUG dlPath: $dlPath"
        buildDropDir=${buildRoot}/siteDir/$dlPath/${buildId}
        echo "DEBGUG buildDropDir: $buildDropDir"
        builderDropDir=${buildDropDir}/${eclipsebuilder}
        echo "DEBUG: builderDropDir: ${builderDropDir}"
    else
        buildRoot=/shared/eclipse/eclipse${eclipseStreamMajor}${buildType}
        buildDir=${buildRoot}/build
        supportDir=${buildDir}/supportDir
        eclipsebuilder=org.eclipse.releng.eclipsebuilder
        builderDir=${supportDir}/$eclipsebuilder
    fi

    # finally, execute (assumed in ../sdk/promotion directory for now
    #${builderDropDir}/startTests.sh ${eclipseStream} ${buildId} ${BUILD_TECH} ${EBUILDER_HASH}
    ./startTests.sh ${eclipseStream} ${buildId} ${BUILD_TECH} ${EBUILDER_HASH}
}

# this funtion currently just synchs up the whole local repo
# with the whole remote repo ... so, important to use --delete and
# provides an easy way to "fix" the remote repo by fixing the local one first.
function syncRepoSite ()
{

    eclipseStream=$1
    if [[ -z "${eclipseStream}" ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: Must provide eclipseStream as first argumnet, for this function $(basename $0)"
        return 1;
    fi


    buildType=$2
    if [[ -z "${buildType}" ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: Must provide buildType as second argumnet, for this function $(basename $0)"
        return 1;
    fi

    BUILD_TECH=$3
    if [[ -z "${BUILD_TECH}" ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: Must provide BUILD_TECH as third argumnet, for this function $(basename $0)"
        return 1;
    fi

    # contrary to intuition (and previous behavior, bash 3.1) do NOT use quotes around right side of expression.
    if [[ "${eclipseStream}" =~ ([[:digit:]]*)\.([[:digit:]]*)\.([[:digit:]]*) ]]
    then
        eclipseStreamMajor=${BASH_REMATCH[1]}
        eclipseStreamMinor=${BASH_REMATCH[2]}
        eclipseStreamService=${BASH_REMATCH[3]}
    else
        echo "eclipseStream, $eclipseStream, must contain major, minor, and service versions, such as 4.2.0"
        exit 1
    fi
    echo "eclipseStream: $eclipseStream"
    echo "eclipseStreamMajor: $eclipseStreamMajor"
    echo "eclipseStreamMinor: $eclipseStreamMinor"
    echo "eclipseStreamService: $eclipseStreamService"
    echo "BUILD_TECH: $BUILD_TECH"
    echo "buildType: $buildType"

    if [[ "${BUILD_TECH}" == 'CBI' ]]
    then 
        buildRoot=/shared/eclipse/builds/${eclipseStreamMajor}${buildType}
    else
        buildRoot=/shared/eclipse/eclipse${eclipseStreamMajor}${buildType}
    fi

    siteDir=${buildRoot}/siteDir

    if [[ "${BUILD_TECH}" == 'CBI' ]]
    then 
        updates=updatescbibased
    else
        updates=updates
    fi

    fromDir=$siteDir/updates/${eclipseStreamMajor}.${eclipseStreamMinor}-${buildType}-builds
    toDir="/home/data/httpd/download.eclipse.org/eclipse/${updates}"

    echo "   In syncRepoSite"
    echo "fromDir: $fromDir"
    echo "toDir: $toDir"

    if [[ "${BUILD_TECH}" == 'CBI' ]]
    then
        echo "skipping syncRepoSite, for now, for CBI"
    else
        # here, for update site, good to maintain times, so
        # we don't re-copy things each time
        # TODO: ideally, for the "new" subdirectory, we would
        # resursively touch first, so its time is "now", time
        # of copy, not time of build.
        # remove -t for now, due to permission problems
        rsync --recursive -t --delete  "${fromDir}" "${toDir}"
    fi
}


# Function is designed with rsync so it can be called
# at multiple times during a build, to make progresive updates.
function syncDropLocation ()
{
    echo "start syncDropLocation"
    eclipseStream=$1
    if [[ -z "${eclipseStream}" ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: Must provide eclipseStream as first argumnet, for this function $(basename $0)"
        return 1;
    fi
    echo "eclipseStream: $eclipseStream"

    buildId=$2
    if [[ -z "${buildId}" ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: Must provide buildId as second argumnet, for this function $(basename $0)"
        return 1;
    fi
    echo "buildId: $buildId"

    BUILD_TECH=$3
    if [[ -z "${BUILD_TECH}" ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: Must provide BUILD_TECH as third argumnet, for this function $(basename $0)"
        return 1;
    fi
    echo "BUILD_TECH: $BUILD_TECH"

    EBUILDER_HASH=$4
    if [[ -z "${EBUILDER_HASH}" ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: Must provide builder (or aggregator) hash as fourth argumnet, for this function $(basename $0)"
        return 1;
    fi
    echo "EBUILDER_HASH: $EBUILDER_HASH"

    eclipseStreamMajor=${eclipseStream:0:1}
    buildType=${buildId:0:1}


    pathToDL=$( dlpath "$eclipseStream" "$buildId" "$BUILD_TECH" )
    echo "pathToDL: $pathToDL"

    if [[ "$pathToDL" == 1 ]]
    then
        printf "\n\n\t%s\n\n" "ERROR: dlpath could not be computed."
        return 1
    fi

    if [[ "${BUILD_TECH}" == 'CBI' ]]
    then 
        buildRoot=/shared/eclipse/builds/${eclipseStreamMajor}${buildType}
    else
        buildRoot=/shared/eclipse/eclipse${eclipseStreamMajor}${buildType}
    fi

    siteDir=${buildRoot}/siteDir

    fromDir=${siteDir}/${pathToDL}/${buildId}
    if [[ ! -d "${fromDir}" ]]
    then
        echo "ERROR: fromDir is not a directory? fromDir: ${fromDir}"
        return 1
    fi

    toDir="/home/data/httpd/download.eclipse.org/${pathToDL}"
    if [[ ! -d "${toDir}" ]]
    then
        echo "ERROR: toDir is not a directory? toDir: ${toDir}"
        return 1
    fi

    echo "   fromDir: ${fromDir}"
    echo "     toDir: ${toDir}"

    # here, for dl site, best not to preserve times, since (if mirrored)
    # would be more accurate for mirroring system to have
    # actual times (and we are copying only one specific
    # sub-sirectory) (But, we do for now, for easier testing) 
    rsync --recursive -t --delete --exclude="*org.eclipse.releng.basebuilder*" --exclude="*eclipse.platform.releng.aggregator*" "${fromDir}" "${toDir}"
    rccode=$?
    if [[ $rccode != 0 ]]
    then
        echo "ERROR: rsync did not complete normally.rccode: $rccode"
        return $rccode
    else
        # if update to downloads succeeded, start the unit tests on Hudson
        startTests $eclipseStreamMajor $buildType $eclipseStream $buildId $BUILD_TECH ${EBUILDER_HASH}
        # Now update main DL page index pages, to show available
        source /shared/eclipse/sdk/updateIndexFilesFunction.shsource
        updateIndex $eclipseStreamMajor $BUILD_TECH
    fi



    echo "ending syncDropLocation"
}







# this is the single script to call that "does it all" to promote build
# to update site, drop site, update index page on downlaods, and send mail to list.
# it requires four arguments
#    eclipseStream (e.g. 4.2 or 3.8)
#    buildId       (e.g. N20120415-2015)
#    BUILD_TECH    (CBI or PDE)
#    EBUILDER_HASH (SHA1 HASH or branch of eclipse builder to used

if [[ $# != 4 ]]
then
    # usage:
    scriptname=$(basename $0)
    printf "\n\t%s\n" "This script, $scriptname requires four arguments, in order: "
    printf "\t\t%s\t%s\n" "eclipseStream" "(e.g. 4.2.2 or 3.8.2) "
    printf "\t\t%s\t%s\n" "buildId" "(e.g. N20120415-2015) "
    printf "\t\t%s\t%s\n" "BUILD_TECH" "(e.g. PDE or CBI) "
    printf "\t\t%s\t%s\n" "EBUILDER_HASH" "(SHA1 HASH for eclipe builder used) "
    printf "\t%s\n" "for example,"
    printf "\t%s\n\n" "./$scriptname 4.2 N N20120415-2015 CBI master"
    exit 1
fi

echo "Starting $0"

eclipseStream=$1
if [[ -z "${eclipseStream}" ]]
then
    printf "\n\n\t%s\n\n" "ERROR: Must provide eclipseStream as first argumnet, for this function $(basename $0)"
    exit 1
fi
echo "eclipseStream: $eclipseStream"

buildId=$2
if [[ -z "${buildId}" ]]
then
    printf "\n\n\t%s\n\n" "ERROR: Must provide buildId as second argumnet, for this function $(basename $0)"
    exit 1
fi
echo "buildId: $buildId"

BUILD_TECH=$3
if [[ -z "${BUILD_TECH}" ]]
then
    printf "\n\n\t%s\n\n" "ERROR: Must provide BUILD_TECH as third argumnet, for this function $(basename $0)"
    exit 1
fi
echo "BUILD_TECH: $BUILD_TECH"

#TODO: asssume master for now, if unspecified. But should tighten up to through error as scripts get finished. 
EBUILDER_HASH=$4
if [[ -z "${EBUILDER_HASH}" ]]
then
    printf "\n\n\t%s\n\n" "WARNING: Must provide builder (or aggregator) hash as fourth argumnet, for this function, $0"
    #printf "\n\n\t%s\n\n" "ERROR: Must provide builder (or aggregator) hash as fourth argumnet, for this function, $0"
    #exit 1;
fi
echo "EBUILDER_HASH: $EBUILDER_HASH"

eclipseStreamMajor=${eclipseStream:0:1}
buildType=${buildId:0:1}
echo "buildType: $buildType"

# call generic fetcher (it checks if it already exists)
toDir=$( dropDir "$eclipseStream" "$buildId" "$BUILD_TECH" )
echo "toDir: $toDir"
if [[ ! -d "${toDir}" ]]
then 
    echo "ERROR: expected toDir (drop directory) did not exist"
    echo "       drop directory: ${toDir}"
    exit 1
fi
SCRIPTDIR=$( dirname $0 )
${SCRIPTDIR}/getEBuilder.sh "${BUILD_TECH}" "${EBUILDER_HASH}" "${toDir}"

syncRepoSite "$eclipseStream" "$buildType" "$BUILD_TECH" "$EBUILDER_HASH"

rccode=$?

if [[ $rccode != 0 ]]
then
    printf "\n\n\t%s\n\n"  "ERROR: something went wrong putting repo on download site. Rest of promoting build halted."
    exit 1
fi


syncDropLocation "$eclipseStream" "$buildId" "$BUILD_TECH" "$EBUILDER_HASH"
rccode=$?
if [[ $rccode != 0 ]]
then
    printf "\n\n\t%s\n\n" "ERROR occurred during promotion to download server, so halted promotion and did not send mail."
    exit 1
fi

sendPromoteMail "$eclipseStream" "$buildId" "$BUILD_TECH"
rccode=$?
if [[ $rccode != 0 ]]
then
    printf "\n\n\t%s\n\n" "ERROR occurred during sending final mail to list"
    exit 1
fi

exit 0
