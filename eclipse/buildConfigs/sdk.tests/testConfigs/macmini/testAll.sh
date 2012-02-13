#!/bin/sh
ulimit -c unlimited

#execute command to run tests
/bin/chmod 755 runtestsmac.sh
./runtestsmac.sh -os macosx -ws cocoa -arch x86 -properties vm.properties > macosx.cocoa_consolelog.txt
exit