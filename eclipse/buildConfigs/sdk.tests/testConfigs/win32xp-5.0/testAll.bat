@echo off
cd %1
REM test script

REM add the extra binaries to the system path
set PATH=%PATH%;%1\..\windowsBin;C:\WRSHDNT

REM run all tests
call runtests.bat -vm ..\jdk1.5.0_11\jre\bin\javaw -properties vm.properties > %2

exit