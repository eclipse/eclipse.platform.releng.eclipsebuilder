# !/bin/sh
cd .
#environment variables
PATH=$PATH:`pwd`/../linux;export PATH
xhost +$HOSTNAME
MOZILLA_FIVE_HOME=/usr/lib/mozilla-1.7.13;export MOZILLA_FIVE_HOME
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MOZILLA_FIVE_HOME
USERNAME=`whoami`
DISPLAY=$HOSTNAME:0.0
ulimit -c unlimited

export USERNAME DISPLAY LD_LIBRARY_PATH

#execute command to run tests

./runtests -os linux -ws gtk -arch x86 -vm `pwd`/../jdk1.4.2_10/jre/bin/java -properties vm.properties 1> linux.gtk_consolelog.txt 2>&1

