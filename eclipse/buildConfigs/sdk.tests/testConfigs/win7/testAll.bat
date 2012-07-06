@echo on
cd %executionDir
REM test script

REM add the extra binaries to the system path
REM set PATH=%PATH%;%executionDir\..\windowsBin

set vmcmdvalue=c:\\java\\jdk7u2\\jre\\bin\\java

REM localTestProperties.bat is not used or expected in production environment, 
REM but allows a place for people to have their own machines variables defined
REM there so they do not have to hand edit each time to do a local build. 
REM a typical example is that their version/location/vendor of VM is likely to differ,
REM so they could redefine vmcmdvalue to what's appropriate to their machine and setup.
call localTestsProperties.bat

REM run all tests
REM runtests.bat -os win32 -ws win32 -arch x86_64 -vm %vmcmdvalue% -properties vm.properties > error.log
mkdir results\consolelogs
runtests.bat -os win32 -ws win32 -arch x86 -vm %vmcmdvalue% -properties vm.properties > results\consolelogs\win7consolelog.txt

exit