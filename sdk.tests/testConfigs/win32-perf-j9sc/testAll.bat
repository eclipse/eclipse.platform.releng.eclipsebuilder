@echo off
cd %1
REM test script

REM add the extra binaries to the system path
set PATH=%PATH%;%1\..\windowsBin

mkdir results\xml
mkdir results\html

REM configure eclipse to use JXE by modifying config.ini
unzip -o -qq eclipse-SDK-%3%-win32.zip *\config.ini
cd eclipse\configuration
echo osgi.framework.extensions=com.ibm.jxesupport>config.ini.tmp
type config.ini >> config.ini.tmp
cp config.ini.tmp config.ini
rm config.ini.tmp

cd  %1

REM add Cloudscape, JXE, and modified config.ini to eclipse
zip eclipse-junit-tests-%3%.zip -rm eclipse

REM run all tests
call runtests.bat -vm ..\jre\bin\java -properties vm.properties "-Dtest.target=performance" "-Dplatform=win32_j9sc_perf">> %2
