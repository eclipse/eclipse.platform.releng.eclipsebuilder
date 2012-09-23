@echo off

REM Is this even needed? If so, probalby should be @exectutionDir@ and it be filled in. 
REM but other scripts don't seem to 
REM echo executionDir: %executionDir%
REM cd %executionDir%

REM test script

REM localTestProperties.bat is not used or expected in production builds,
REM but is needed for production performance tests and  
REM allows a place for people to have their own machines variables defined
REM there so they do not have to hand edit each time to do a local build. 
REM a typical example is that their version/location/vendor of VM is likely to differ,
REM so they could redefine vmcmdvalue to what's appropriate to their machine and setup.
IF EXIST localTestProperties.bat call localTestProperties.bat 

REM vm.properties is used by default on production machines, but will 
REM need to override on local setups and performance tests
IF NOT DEFINED propertyFile SET propertyFile=vm.properties

IF NOT DEFINED vmcmdvalue SET vmcmdvalue=c:\\java\\jdk7u2\\jre\\bin\\javaw


mkdir results\consolelogs
runtests.bat -os win32 -ws win32 -arch x86 -vm %vmcmdvalue% -properties %propertyFile% %* > results\consolelogs\win7consolelog.txt

exit 