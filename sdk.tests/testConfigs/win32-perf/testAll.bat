@echo off
cd %1
REM test script

REM add the extra binaries to the system path
set PATH=%PATH%;%1\..\windowsBin

REM run all tests
call runtests.bat -vm ..\jdk1.4.2_03\jre\bin\java "-Dperformance=true" "-Dplatform=winxp_perf" "-Dperf.host=eclipseperf.torolab.ibm.com" "-Dperf.port=9080" "-Dperf.id=sdimitro" >> %2