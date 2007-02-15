# !/bin/sh
ulimit -c unlimited

#execute command to run tests
./runtests -os macosx -ws carbon -arch ppc -properties `pwd`/vm.properties 1> macosx.carbon_consolelog.txt 2>&1

