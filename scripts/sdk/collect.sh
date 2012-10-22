#!/usr/bin/env bash 

# Utility to be called from test data collection cron job, 
# to invoke the main code. expected to be called with piped 
# input, such as
# ./collect.sh < testjobs/testjobdata201210220811.txt


export JAVA_HOME=/shared/common/jdk1.7.0
export ANT_HOME=/shared/common/apache-ant-1.8.4

read inputline
echo "inputline: $inputline"

job="$(echo $inputline | cut -d\  -f1)"
buildNumber="$(echo $inputline | cut -d\  -f2)"
buildId="$(echo $inputline | cut -d\  -f3)"
eclipseStream="$(echo $inputline | cut -d\  -f4)"

echo "job: $job"
echo "buildNumber: $buildNumber"
echo "buildId: $buildId"
echo "eclipseStream: $eclipseStream"

# Uncomment once ready, but synchronize "release" of code with 
# removing the check/wait loop in invokeTestsJSON.xml

${ANT_HOME}/bin/ant -f /shared/eclipse/sdk/collectTestResults.xml \
      -lib /shared/common/apache-ant-1.8.4/lib/ \
   -Djob=${job} \
   -DbuildNumber=${buildNumber} \
   -DbuildId=${buildId} \
   -DeclipseStream=${eclipseStream}
