#! /bin/sh
ulimit -c unlimited

#execute command to run tests
./runtests -vm "java -XstartOnFirstThread" -os macosx -ws carbon -arch ppc -properties vm.properties> macosx.carbon_consolelog.txt

