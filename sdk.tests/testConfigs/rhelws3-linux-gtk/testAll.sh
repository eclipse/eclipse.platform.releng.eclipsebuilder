# !/bin/sh
cd .
#environment variables
PATH=.:/bin:/usr/bin:/usr/bin/X11:/usr/local/bin:/usr/X11R6/bin:`pwd`/../linux;export PATH
xhost +$HOSTNAME
#LD_ASSUME_KERNEL=2.2.5
LD_LIBRARY_PATH=.
USERNAME=`whoami`
DISPLAY=$HOSTNAME:0.0
ulimit -c unlimited

export LD_ASSUME_KERNEL LD_LIBRARY_PATH USERNAME DISPLAY

#execute command to run tests

./runtests -os linux -ws gtk -arch x86 -Dplatform=linux.gtk -vm ../jdk1.4.2_03/jre/bin/java> linux.gtk_consolelog.txt


