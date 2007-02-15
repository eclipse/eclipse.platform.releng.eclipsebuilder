# !/bin/sh
cd .
#environment variables
PATH=$PATH:`pwd`/../linux;export PATH
xhost +$HOSTNAME
USERNAME=`whoami`
DISPLAY=$HOSTNAME:0.0
ulimit -c unlimited

export USERNAME DISPLAY

# add Cloudscape plugin to junit tests zip file
zip eclipse-junit-tests-$1.zip -rm eclipse

#all tests
./runtests -os linux -ws gtk -arch x86 -vm `pwd`/../jdk1.4.2_10/jre/bin/java -properties vm.properties -Dtest.target=performance -Dplatform=linux.gtk.perf3 1> linux.gtk.perf3_consolelog.txt 2>&1


