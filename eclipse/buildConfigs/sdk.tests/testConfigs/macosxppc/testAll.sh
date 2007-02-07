# !/bin/sh
ulimit -c unlimited

#execute command to run tests
./runtests -os macosx -ws carbon -arch ppc -properties `pwd`/vm.properties> macosx.carbon_consolelog.txt

