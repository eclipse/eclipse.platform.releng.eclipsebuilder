# !/bin/sh
cd .
#environment variables
PATH=.:/bin:/usr/bin:/usr/bin/X11:/usr/local/bin:/usr/X11R6/bin:`pwd`/../linux;export PATH
xhost +$HOSTNAME
MOZILLA_FIVE_HOME=/usr/lib/mozilla-1.4;export MOZILLA_FIVE_HOME
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MOZILLA_FIVE_HOME
USERNAME=`whoami`
DISPLAY=$HOSTNAME:0.0
ulimit -c unlimited

export LD_LIBRARY_PATH USERNAME DISPLAY

REM add Cloudscape plugin to junit tests zip file
zip eclipse-junit-tests-$1.zip -rm eclipse

#execute command to run tests
./runtests -noupdate -os linux -ws gtk -arch x86 -vm ../jdk1.4.2_06/jre/bin/java -properties vm.properties -Dtest.target=performance -Dplatform=linux.gtk.perf> linux.gtk.perf_consolelog.txt


