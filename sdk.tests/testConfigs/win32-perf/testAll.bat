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

REM run team cvs tests with different vm args
call runtests.bat teamcvs -vm ..\jdk1.4.2_06\jre\bin\java -properties team.properties "-Dtest.target=performance" "-Dplatform=win32perf"> %2

REM run all tests
call runtests.bat -vm ..\jdk1.4.2_06\jre\bin\java -properties vm.properties "-Dtest.target=performance" "-Dplatform=win32perf" "-Dexclude.teamcvs.test=true">> %2
