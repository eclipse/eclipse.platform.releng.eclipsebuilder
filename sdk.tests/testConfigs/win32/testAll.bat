@echo off
cd %1
REM test script

REM add the extra binaries to the system path
set PATH=%PATH%;%1\..\windowsBin

REM run all tests
call runtests.bat -vm ..\jdk1.4.2_06\jre\bin\java "-Dplatform=winxp">> %2