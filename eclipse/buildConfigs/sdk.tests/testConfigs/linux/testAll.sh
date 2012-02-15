#!/bin/sh
cd .
#export MOZILLA_FIVE_HOME=/usr/lib64/xulrunner-1.9.0.6;export MOZILLA_FIVE_HOME
export MOZILLA_FIVE_HOME=/usr/lib/xulrunner-1.9.0.19;export MOZILLA_FIVE_HOME

/bin/chmod 755 runtests.sh
./runtests.sh -os linux -ws gtk -arch x86_64 -vm /shared/common/jdk-1.6.x86_64/jre/bin/java -properties vm.properties > linux.gtk-6.0_consolelog.txt
#./runtests.sh -os linux -ws gtk -arch x86 -vm /shared/common/jdk-1.6.0_10/jre/bin/java -properties vm.properties > linux.gtk-6.0_consolelog.txt
exit 
