# !/bin/sh
ulimit -c unlimited

#execute command to run tests
./runtests -os macosx -ws carbon -arch ppc -properties vm.properties> macosx.carbon_consolelog.txt

#run JDT Core tests on 1.5 vm
#./runtests -os macosx -ws carbon -arch ppc -vm ../jdk1.5.0_03/jre/bin/java -properties vm.properties all5.0>> macosx.carbon_consolelog.txt
