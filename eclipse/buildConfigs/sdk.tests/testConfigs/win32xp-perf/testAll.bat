@echo off
cd %1
REM test script

mkdir results

REM add Cloudscape plugin to junit tests zip file
zip eclipse-junit-tests-%3%.zip -rm eclipse

REM run all tests
call runtests.bat -vm %cd%\..\jdk1.4.2_10\jre\bin\javaw -properties vm.properties "-Dtest.target=performance" "-Dplatform=win32perf" > %2
exit