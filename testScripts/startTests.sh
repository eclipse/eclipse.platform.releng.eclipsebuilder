#!/usr/bin/env bash

# Small utility to start unit tests (or re-run them) after a build (and initial tests) 
# is complete. 

source buildParams.shsource

buildType=${buildType:-M}
buildId=${buildId:-M20120705-1200}
eclipseStream=${eclipseStream:-4.2.1}

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
echo "buildType: $buildType"
echo "buildId: $buildId"

buildLabel=${buildId}
buildRoot=/shared/eclipse/eclipse${eclipseStreamMajor}${buildType}
buildDir=${buildRoot}/build
supportDir=${buildDir}/supportDir
eclipsebuilder=org.eclipse.releng.eclipsebuilder
builderDir=${supportDir}/$eclipsebuilder

# should buildDirectory be set at "main" one from actual build? 
buildDirectory=${supportDir}/src

# note, to be consistent, I changed json xml file so it adds buildId to postingDirectory 
siteDir=${buildRoot}/siteDir
postingDirectory=${siteDir}/eclipse/downloads/drops
if [[ "${eclipseStreamMajor}" > 3 ]]
then
    postingDirectory=${siteDir}/eclipse/downloads/drops${eclipseStreamMajor}
fi

HUDSON_TOKEN=windows2012tests ant \
-DbuildDirectory=${buildDirectory} \
-DpostingDirectory=${postingDirectory} \
-DbuildId=${buildId} \
-DbuildType=${buildType} \
-DeclipseStream=${eclipseStream} \
-DeclipseStreamMajor=${eclipseStreamMajor} \
-f ${builderDir}/invokeTestsJSON.xml 

