# !/bin/sh
ulimit -c unlimited
PATH=/System/Library/Frameworks/JavaVM.framework/Versions/1.4.2/Commands/:$PATH;export PATH

#execute command to run tests
./runtests -vm "java -XstartOnFirstThread" -os macosx -ws carbon -arch ppc -properties vm.properties> macosx.carbon_consolelog.txt

