@echo off
cd %1
REM test script

REM add the extra binaries to the system path
set PATH=%PATH%;%1\..\windowsBin

mkdir results\xml
mkdir results\html
mkdir results\performance

REM add Cloudscape plugin to junit tests zip file
zip eclipse-junit-tests-%3%.zip -rm eclipse

REM run all tests
call runtests.bat -vm ..\jdk1.4.2_08\jre\bin\java -properties vm.properties "-Dtest.target=performance" "-Dplatform=win32.perf2" > %2
