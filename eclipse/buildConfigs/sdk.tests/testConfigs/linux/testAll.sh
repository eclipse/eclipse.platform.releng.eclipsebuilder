#!/bin/sh
cd .
export MOZILLA_FIVE_HOME=/usr/lib/mozilla-1.7.12;export MOZILLA_FIVE_HOME

/bin/chmod 755 runtests.sh
./runtests.sh -os linux -ws gtk -arch x86_64 -vm /shared/common/jdk-1.6.x86_64/jre/bin/java -properties vm.properties > linux.gtk-6.0_consolelog.txt
exit 
