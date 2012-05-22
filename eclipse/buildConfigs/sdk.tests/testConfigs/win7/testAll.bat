@echo on
cd %executionDir
REM test script

REM add the extra binaries to the system path
REM set PATH=%PATH%;%executionDir\..\windowsBin

REM run all tests
REM runtests.bat -os win32 -ws win32 -arch x86_64 -vm c:\\java\\jdk1.6.0_20\\jre\\bin\\javaw -properties vm.properties > error.log
mkdir results\consolelogs
runtests.bat -os win32 -ws win32 -arch x86 -vm c:\\java\\jdk7u2\\jre\\bin\\javaw -properties vm.properties > results\consolelogs\win7consolelog.txt

exit