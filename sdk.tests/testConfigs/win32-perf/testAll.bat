@echo off
cd %1
REM test script

REM add the extra binaries to the system path
set PATH=%PATH%;%1\..\windowsBin

mkdir results\xml
mkdir results\html
mkdir results\performance

REM run all tests
call runtests.bat -vm ..\jre\bin\java -properties vm.properties "-Dtest.target=performance" "-Dperformance=true" "-Dplatform=winxp_perf" "-Dperf.host=eclipseperf.torolab.ibm.com" "-Dperf.port=9080" "-Dperf.id=sdimitro" >> %2
