# !/bin/sh
cd $1
#environment variables
xhost +$HOSTNAME
MOZILLA_FIVE_HOME=/usr/lib/mozilla-1.4;export MOZILLA_FIVE_HOME
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MOZILLA_FIVE_HOME
USERNAME=`whoami`
DISPLAY=$HOSTNAME:0.0
ulimit -c unlimited

export LD_LIBRARY_PATH USERNAME DISPLAY

#execute command to run tests

./runtests -os linux -ws gtk -arch x86 -vm ../jdk1.4.2_06/jre/bin/java -properties vm.properties -Dtest.target=performance -Dplatform=linux.gtk.perf $2> $3


