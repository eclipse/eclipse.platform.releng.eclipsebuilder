@echo off
cd %1
REM test script

set APT_HOME=%1\apt

REM add the extra binaries to the system path
set PATH=%PATH%;%1\..\windowsBin;%1\..\jre\bin

REM run all tests
call runtests.bat -properties vm.properties "-Dperformance=true" "-Dplatform=winxp_perf" "-Dperf.host=eclipseperf.torolab.ibm.com" "-Dperf.port=9080" "-Dperf.id=sdimitro" >> %2