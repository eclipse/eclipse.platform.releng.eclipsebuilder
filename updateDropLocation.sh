#!/usr/bin/env bash



# Function is designed with rsync so it can be called 
# at multiple times during a build, to make progresive updates.
function updateDropLocation () 
{
    echo "start updateDropLocation"
    eclipseStream=$1
    if [ -z "${eclipseStream}" ]
    then
        echo "must provide eclispeStream as first argumnet, for this function $0"
        return 1;
    fi


    buildType=$2
    if [ -z "${buildType}" ]
    then
        echo "must provide buildType as second argumnet, for this function $0"
        return 1;
    fi

    buildId=$3
    if [ -z "${buildId}" ]
    then
        echo "must provide buildId as third argumnet, for this function $0"
        return 1;
    fi

    eclipseStreamMajor=${eclipseStream:0:1}

    pathToDL=eclipse/downloads/drops
    if [[ $eclipseStreamMajor > 3 ]]
    then 
        pathToDL=eclipse/downloads/drops$eclipseStreamMajor
    fi


    buildRoot=${buildRoot:-/shared/eclipse/eclipse${eclipseStreamMajor}${buildType}}
    siteDir=${buildRoot}/siteDir

    fromDir=${siteDir}/${pathToDL}/${buildId}
    if [ ! -d "${fromDir}" ]
    then
        echo "ERROR: fromDir is not a direcotry? fromDir: ${fromDir}"
        return 1
    fi

    toDir="/home/data/httpd/download.eclipse.org/${pathToDL}"
    if [ ! -d "${toDir}" ]
    then
        echo "ERROR: toDir is not a direcotry? toDir: ${toDir}"
        return 1
    fi

    echo "   fromDir: ${fromDir}"
    echo "     toDir: ${toDir}"

    # here, for updating dl site, best to preserve times, 
    # but only if initial first-time upload are all "touched" to 
    # have "current time" (otherwise, that first time throws off mirrors, 
    # and to "change" times at this point would be bad ... sending some 
    # "back in time"? 
    # TODO: we probably only need to do this for a few types of files, but not sure 
    # which yet .. PHP, XML?, HTML? properties? 
    rsync --recursive "${fromDir}" "${toDir}"
    rccode=$?
    if [ $rccode -ne 0 ]
    then
        echo "ERROR: rsync did not complete normally.rccode: $rccode"
        return $rccode
    else
        if [[ $eclipseStreamMajor == 3 ]]         
        then
            wget -O index3.txt http://download.eclipse.org/eclipse/downloads/eclipse3x.php
            rccode=$?
            if [ $rccode -eq 0 ]
            then
                rsync  index3.txt /home/data/httpd/download.eclipse.org/eclipse/downloads/eclipse3x.html
                rccode=$?
                if [ $rccode -eq 0 ] 
                then
                    echo "INFO: Upated http://download.eclipse.org/eclipse/downloads/eclipse3x.html"
                    return 0
                else
                    echo "ERROR: Could not copy index3.html to downlaods. rccode: $rccode"
                    return $rccode
                fi
            else
                echo "ERROR: Could not create index3.html from downlaods. rccode: $rccode"
                return $rccode
            fi
        else
            # assume major version if 4    
            wget -O index.txt http://download.eclipse.org/eclipse/downloads/createIndex4x.php
            rccode=$?
            if [ $rccode -eq 0 ]
            then
                rsync  index.txt /home/data/httpd/download.eclipse.org/eclipse/downloads/index.html
                rccode=$?
                if [ $rccode -eq 0 ] 
                then
                    echo "INFO: Upated http://download.eclipse.org/eclipse/downloads/index.html"
                    return 0
                else
                    echo "ERROR: Could not copy index.html to downlaods. rccode: $rccode"
                    return $rccode
                fi
            else
                echo "ERROR: Could not create index.html from downlaods. rccode: $rccode"
                return $rccode
            fi
        fi
    fi
}


# may be hard to know when to send test mail ... we'd have to make 
# sure they are all done?
function sendTestMail ()
{

    eclipseStream=$1
    if [ -z "${eclipseStream}" ]
    then
        echo "must provide eclispeStream as first argumnet"
        exit 1;
    fi


    buildType=$2
    if [ -z "${buildType}" ]
    then
        echo "must provide buildType as second argumnet"
        exit 1;
    fi
    buildId=$3
    if [ -z "${buildId}" ]
    then
        echo "must provide buildId as third argumnet"
        exit 1;
    fi

    # ideally, the user executing this mail will have this special file in their home direcotry,
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

    eclipseStreamMajor=${eclipseStream:0:1}

    mainPath=eclipse/downloads/drops
    if [[ $eclipseStreamMajor > 3 ]]
    then 
        mainPath=eclipse/downloads/drops$eclipseStreamMajor
    fi

    downloadURL=http://download.eclipse.org/${mainPath}/${buildId}/



    # 4.2 Build: I20120411-2034
    SUBJECT="${eclipseStream} ${buildType}-Build: ${buildId}"

    # wtp-dev for promotes, wtp-releng for smoketest requests
    TO="platform-releng-dev@eclipse.org"
    # for tests
    #TO="david_williams@us.ibm.com"

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
    http://download.eclipse.org/eclipse/updates/${eclipseStreamMajor}.${eclipseStreamMinor}-${buildType}-builds

EOF

    echo "mail sent for $eclipseStream $buildType-build $buildId"
    return 0
}




# this is the single script to call that "does it all" to promote build 
# to update site, drop site, update index page on downlaods, and send mail to list.

# it requires three arguments
#    eclipseStream (e.g. 4.2 or 3.8) 
#    buildType     (e.g. I or N) 
#    buildId       (e.g. N20120415-2015)


if [[ $# != 3 ]]
then
    # usage: 
    scriptname=$(basename $0)
    printf "\n\t%s\n" "This script, $scriptname requires three arguments, in order: "
    printf "\t\t%s\t%s\n" "eclipseStream" "(e.g. 4.2.0 or 3.8.0) "
    printf "\t\t%s\t%s\n" "buildType" "(e.g. I or N) "
    printf "\t\t%s\t%s\n" "buildId" "(e.g. N20120415-2015) "
    printf "\t%s\n" "for example," 
    printf "\t%s\n\n" "./$scriptname 4.2.0 N N20120415-2015"
    exit 1
fi

eclipseStream=$1
if [ -z "${eclipseStream}" ]
then
    echo "must provide eclispeStream as first argumnet, for this function $0"
    return 1;
fi


buildType=$2
if [ -z "${buildType}" ]
then
    echo "must provide buildType as second argumnet, for this function $0"
    return 1;
fi

buildId=$3
if [ -z "${buildId}" ]
then
    echo "must provide buildId as third argumnet, for this function $0"
    return 1;
fi


updateDropLocation $1 $2 $3

rccode=$?

if [ $rccode -ne 0 ] 
then 
    echo "ERROR occurred during promotion to download serve: rccode: $rccode."
    exit $rccode
fi 

exit 0

# may be hard to know when to send test mail ... we'd have to make 
# sure they are all done?
#sendTestMail $1 $2 $3
#rccode=$?
#if [ $rccode -ne 0 ] 
#then 
#  echo "ERROR occurred during sending final mail to list"
#  exit 1
#fi 


