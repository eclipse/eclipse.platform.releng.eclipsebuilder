@echo off
cd %1

REM run all tests
call runtests.bat -vm ..\jdk1.4.2_06\jre\bin\java -properties vm.properties "-Dtest.target=performance" "-Dplatform=win32perf" %2 > %3
