@echo off
cd %1
REM test script

REM add the extra binaries to the system path
set PATH=%PATH%;%1\..\windowsBin

REM run all tests
call runtests.bat -vm %cd%\..\jdk1.4.2_14\jre\bin\javaw -properties vm.properties > %2

exit