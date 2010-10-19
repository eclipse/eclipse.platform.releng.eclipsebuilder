@echo on
cd %executionDir
REM test script

REM add the extra binaries to the system path
REM set PATH=%PATH%;%executionDir\..\windowsBin

REM run all tests
REM call runtests.bat -vm \"c:\Program Files\Java\jdk1.6.0_20\jre\bin\javaw\" -properties vm.properties > error.log
runtests.bat -os win32 -ws win32 -arch x86_64 -properties vm.properties > error.log

exit