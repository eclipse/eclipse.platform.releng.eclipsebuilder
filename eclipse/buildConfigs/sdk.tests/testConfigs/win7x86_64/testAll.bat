@echo off
cd %1
REM test script

REM add the extra binaries to the system path
set PATH=%PATH%;%1\..\windowsBin

REM run all tests
call runtests.bat -vm "c:\Program Files\Java\jdk1.6.0_20\jre\bin\javaw" -properties vm.properties > error.log

exit