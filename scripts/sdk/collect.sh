
export JAVA_HOME=/shared/common/jdk1.7.0
export ANT_HOME=/shared/common/apache-ant-1.8.4

${ANT_HOME}/bin/ant -f collectTestResults.xml \
   -lib /shared/common/apache-ant-1.8.4/lib/ \
   -Djob=ep3-unit-mac64 \
   -DbuildNumber=5 \
   -DbuildId=M20121017-1000  \
   -DeclipseStream=3.8.2
