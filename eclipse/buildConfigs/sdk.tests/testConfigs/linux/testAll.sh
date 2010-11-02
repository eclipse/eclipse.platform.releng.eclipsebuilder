#!/bin/sh
cd .
#environment variables
echo localhost > auth.cfg
Xvfb :8 -screen 0 1280x1024x24 -auth auth.cfg &
#DISPLAY=$HOSTNAME:0.0
DISPLAY=:8.0 metacity --display=:8.0 --replace --sm-disable >/dev/null 2>&1 &
PATH=$PATH:`pwd`/../linux;export PATH
#xhost +$HOSTNAME
MOZILLA_FIVE_HOME=/usr/lib/firefox-1.5.0.12; export MOZILLA_FIVE_HOME
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MOZILLA_FIVE_HOME
#USERNAME=`whoami`
ulimit -c unlimited

export DISPLAY LD_LIBRARY_PATH
ls -la runtests
#execute command to run tests
/bin/chmod 755 runtests
ls -la runtests
ls -la /shared/common/jdk-1.6.x86_64/bin/java
./runtests -os linux -ws gtk -arch x86_64 -vm /shared/common/jdk-1.6.x86_64/bin/java -properties vm.properties > linux.gtk-6.0_consolelog.txt 
