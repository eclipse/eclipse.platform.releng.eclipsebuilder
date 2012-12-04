#!/usr/bin/env bash

# utility to get a "fresh" copy of maps-builder overlay 
# For now assumes eclipseBuilder and maps are up to date (i.e. those utilities already ran)

function debugVar ()
{
    if [[ "${DEBUG}" == "true" ]]
    then
        variablenametodisplay=$1
        eval variableValue=\$${variablenametodisplay}
        echo "DEBUG VAR: ${variablenametodisplay}: ${variableValue}"
    fi
}
function debugMsg ()
{
    if [[ "${DEBUG}" == "true" ]]
    then
        message=$1
        echo "DEBUG MSG: ${message}"
    fi
}

# TODO: make into variables to pass in, check, keep off of eclipseStream, etc.
#supportDir=/shared/eclipse/eclipse4N/build/supportDir
supportDir=${PWD}

debugVar "${supportDir}"

buildDirectory="${supportDir}/src"

mapsProjectName=org.eclipse.maps

mapDir="${buildDirectory}/maps"

debugVar "${mapDir}"

overlayDir="${mapDir}/org.eclipse.releng/configuration/eclipseBuilderOverlays"

eclipseBuilderDir="${supportDir}/org.eclipse.releng.eclipsebuilder"

if [[ ! -d "${overlayDir}" ]]
then
    echo "ERROR: expected overlay directory did not exist"
    echo "       expected: ${overlayDir}"
    exit 1
fi

# ditto
if [[ ! -d "${eclipseBuilderDir}" ]]
then
    echo "ERROR: expected eclipsebuilder directory did not exist"
    echo "       expected: ${eclipseBuilderDir}"
    exit 1
fi

rsync -vr "${overlayDir}/" "${eclipseBuilderDir}/"
RC=$?
if [[ $RC != 0 ]]
 then
  echo "rsync from maps overlay directory to eclipseBuiderDir failed: $RC"
  exit $RC
fi

exit 0