@echo off

REM default java executable for outer and test vm
set vmcmd=
set testvm=

REM reset list of ant targets in test.xml to execute
set tests=

REM default switch to determine if eclipse should be reinstalled between running of tests
set installmode=clean

REM property file to pass to Ant scripts
set properties=

REM default values for os, ws and arch
set os=win32
set ws=win32
set arch=x86

REM reset ant command line args
set ANT_CMD_LINE_ARGS=

REM ****************************************************************
REM
REM Install Eclipse if it does not exist
REM
REM ****************************************************************
if NOT EXIST eclipse unzip -qq -o eclipse-SDK-*.zip && unzip -qq -o -C eclipse-junit-tests*.zip */plugins/org.eclipse.test*


:processcmdlineargs

REM ****************************************************************
REM
REM Process command line arguments
REM
REM ****************************************************************

if x%1==x goto run
if x%1==x-ws set ws=%2 && shift && shift && goto processcmdlineargs
if x%1==x-os set os =%2 && shift && shift && goto processcmdlineargs
if x%1==x-arch set arch=%2 && shift && shift && goto processcmdlineargs
if x%1==x-noclean set installmode=noclean&& shift && goto processcmdlineargs
if x%1==x-properties set properties=-propertyfile %2 && shift && shift && goto processcmdlineargs
if x%1==x-vm set vmcmd="-vm %2" && set testvm="-Djvm=%2" && shift && shift && goto processcmdlineargs

set tests=%tests% %1 && shift && goto processcmdlineargs


:run
REM ***************************************************************************
REM	Run tests by running Ant in Eclipse on the test.xml script
REM ***************************************************************************
eclipse\eclipse.exe %vmcmd% -data workspace -nosplash -suppressErrors -application org.eclipse.ant.core.antRunner -file test.xml %tests% %testvm% -Dws=%ws% -Dos=%os% -Darch=%arch% -D%installmode%=true %properties% -logger org.apache.tools.ant.DefaultLogger -vmargs -Xmx512m
goto end

:end
