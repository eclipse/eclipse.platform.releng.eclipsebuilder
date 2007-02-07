# !/bin/sh
cd .
#environment variables
PATH=$PATH:`pwd`/../linux;export PATH
xhost +$HOSTNAME
USERNAME=`whoami`
DISPLAY=$HOSTNAME:0.0
ulimit -c unlimited

export USERNAME DISPLAY

#execute command to run tests

./runtests -os linux -ws gtk -arch x86 -vm `pwd`/../jdk1.4.2_10/jre/bin/java -properties vm.properties> linux.gtk_consolelog.txt

