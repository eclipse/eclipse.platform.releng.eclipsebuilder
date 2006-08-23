#!/bin/sh
cd .
#environment variables
PATH=.:/bin:/usr/bin:/usr/bin/X11:/usr/local/bin:/usr/X11R6/bin:`pwd`/../linux;export PATH
xhost +$HOSTNAME
MOZILLA_FIVE_HOME=/usr/lib/mozilla-1.7.13;export MOZILLA_FIVE_HOME 
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MOZILLA_FIVE_HOME 
USERNAME=`whoami`
DISPLAY=$HOSTNAME:0.0
ulimit -c unlimited

export LD_LIBRARY_PATH USERNAME DISPLAY

#execute command to run tests

./runtests -os linux -ws gtk -arch x86 -vm ../jdk1.5.0_06/jre/bin/java -properties vm.properties> linux.gtk-5.0_consolelog.txt
