@echo off
cd %1
REM test script

REM add the extra binaries to the system path
set PATH=%PATH%;%1\..\windowsBin

REM run all tests
call runtests.bat -vm ..\jdk1.4.2_08\jre\bin\java>> %2

REM run JDT Core tests on 1.5 vm
call runtests.bat -vm ..\jdk1.5.0_03\jre\bin\java all5.0>> %2
exit