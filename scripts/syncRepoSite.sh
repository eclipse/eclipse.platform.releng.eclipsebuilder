#!/usr/bin/env bash


function syncRepoSite () 
{

    buildType=${buildType:-N}
    eclipseStream=${eclipseStream:-4.2}
    eclipseStreamMajor=${eclipseStream:0:1}
    echo "buildType: $buildType"
    echo "eclipseStream: $eclipseStream"
    echo "eclipseStreamMajor: $eclipseStreamMajor"

    buildRoot=${buildRoot:-/shared/eclipse/eclipse${eclipseStreamMajor}${buildType}}
    siteDir=${buildRoot}/siteDir

    fromDir=$siteDir/updates/${eclipseStream}-${buildType}-builds
    toDir="/home/data/httpd/download.eclipse.org/eclipse/updates"

    rsync --recursive --delete "${fromDir}" "${toDir}"
}

syncRepoSite

