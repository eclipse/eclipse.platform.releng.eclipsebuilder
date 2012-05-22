#!/bin/sh
ulimit -c unlimited

#execute command to run tests
/bin/chmod 755 runtestsmac.sh
/bin/mkdir -p results/consolelogs
./runtestsmac.sh -os macosx -ws cocoa -arch x86 -properties vm.properties > results/consolelogs/macosx.cocoa_consolelog.txt
exit