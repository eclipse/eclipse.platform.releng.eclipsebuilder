#! /bin/sh
cd .
#environment variables
PATH=.:/bin:/usr/bin:/usr/bin/X11:/usr/local/bin:/usr/X11R6/bin:`pwd`/../linux;export PATH
xhost +$HOSTNAME
MOZILLA_FIVE_HOME=/usr/lib/mozilla-1.7.7;export MOZILLA_FIVE_HOME
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MOZILLA_FIVE_HOME
USERNAME=`whoami`
DISPLAY=$HOSTNAME:0.0
ulimit -c unlimited

export LD_LIBRARY_PATH USERNAME DISPLAY
mkdir -p results/xml
mkdir -p results/html

# add Cloudscape plugin to junit tests zip file
zip eclipse-junit-tests-$1.zip -rm eclipse

#all tests
./runtests -os linux -ws gtk -arch x86 -vm ../jdk1.4.2_10/jre/bin/java -properties vm.properties -Dtest.target=performance -Dplatform=linux.gtk.perf3 > linux.gtk.perf3_consolelog.txt


