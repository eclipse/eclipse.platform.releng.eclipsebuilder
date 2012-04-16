#!/usr/bin/env bash

# Function is designed with rsync so it can be called 
# at multiple times during a build, to make progresive updates.

function syncDropLocation () 
{
    eclipseStream=$1
    if [ -z "${eclipseStream}" ]
    then
       echo "must provide eclispeStream as first argumnet, for this function $0"
       exit 1;
    fi


    buildType=$2
    if [ -z "${buildType}" ]
    then
        echo "must provide buildType as second argumnet, for this function $0"
        exit 1;
    fi
 
    buildId=$3
    if [ -z "${buildId}" ]
    then
         echo "must provide buildId as third argumnet, for this function $0"
         exit 1;
     fi
    
    pathToDL=eclipse/downloads/drops4
    
    eclipseStreamMajor=${eclipseStream:0:1}
    echo "buildType: $buildType"
    echo "eclipseStream: $eclipseStream"
    echo "eclipseStreamMajor: $eclipseStreamMajor"

    buildRoot=${buildRoot:-/shared/eclipse/eclipse${eclipseStreamMajor}${buildType}}
    siteDir=${buildRoot}/siteDir

    fromDir=${siteDir}/${pathToDL}/${buildId}
    if [ ! -d "${fromDir}" ]
    then
        echo "ERROR: fromDir is not a direcotry? fromDir: ${fromDir}"
        exit 1
    fi

    toDir="/home/data/httpd/download.eclipse.org/${pathToDL}"
    if [ ! -d "${toDir}" ]
    then
        echo "ERROR: toDir is not a direcotry? toDir: ${toDir}"
        exit 1
    fi

    echo "   fromDir: ${fromDir}"
    echo "     toDir: ${toDir}"

    rsync -p -t --recursive --delete "${fromDir}" "${toDir}"
    rccode=$?
    if [ $rccode -ne 0 ]
    then
        echo "ERROR: rsync did not complete normally.rccode: $rccode"
        exit $rccode
    else
        wget -O index.txt http://download.eclipse.org/eclipse/downloads/createIndex4x.php
        rccode=$?
        if [ $rccode -eq 0 ]
        then
            rsync -p -t index.txt /home/data/httpd/download.eclipse.org/eclipse/downloads/index.html
            rccode=$?
            if [ $rccode -eq 0 ] 
            then
                echo "INFO: Upated http://download.eclipse.org/eclipse/downloads/index.html"
            else
                echo "ERROR: Could not copy index.html to downlaods. rccode: $rccode"
                exit $rccode
            fi
        else
            echo "ERROR: Could not create index.html from downlaods. rccode: $rccode"
            exit $rccode
        fi

    fi
}

syncDropLocation $1 $2 $3

source sendPromoteMail.sh

sendPromoteMail $1 $2 $3
