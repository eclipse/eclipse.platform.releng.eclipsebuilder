# !/bin/sh
ulimit -c unlimited

#execute command to run tests
./runtests -vm "java -XstartOnFirstThread" -os macosx -ws carbon -arch ppc -properties vm.properties> macosx.carbon_consolelog.txt

#run JDT Core tests on 1.5 vm
./runtests -os macosx -ws carbon -arch ppc -vm "/System/Library/Frameworks/JavaVM.framework/Versions/1.5.0/Commands/java -XstartOnFirstThread" -properties vm.properties all5.0>> macosx.carbon_consolelog.txt
