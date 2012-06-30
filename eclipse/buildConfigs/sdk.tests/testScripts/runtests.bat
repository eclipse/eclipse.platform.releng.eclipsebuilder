@echo off

REM default java executable for outer and test vm
set vmcmd=java
setx no_proxy=localhost,127.0.0.1,172.30.206.0,dev.eclipse.org,hudson.eclipse.org,eclipse.org

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
if NOT EXIST eclipse unzip -qq -o eclipse-SDK-*.zip && unzip -qq -o -C eclipse-junit-tests*.zip plugins/org.eclipse.test* -d eclipse/dropins/


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
if x%1==x-vm set vmcmd="%2" && shift && shift && goto processcmdlineargs

set tests=%tests% %1 && shift && goto processcmdlineargs


:run
REM ***************************************************************************
REM	Run tests by running Ant in Eclipse on the test.xml script
REM ***************************************************************************
REM get name of org.eclipse.equinox.launcher_*.jar with version label
dir /b eclipse\plugins\org.eclipse.equinox.launcher_*.jar>launcher-jar-name.txt
set /p launcher-jar=<launcher-jar-name.txt


rem tried using these as experiements for bug 372880
rem https://bugs.eclipse.org/bugs/show_bug.cgi?id=372880
rem set /p http.nonProxyHosts="127.0.0.1|localhost|*.localhost|local|*.local|169.254/16|*.169.254/16|eclipse.org|*.eclipse.org|hudson.eclipse.org|*.hudson.eclipse.org|dev.eclipse.org|*.dev.eclipse.org"
rem -Dhttp.nonProxyHosts=%http.nonProxyHosts%
rem -Dtimeout=1800000

echo "list all environment variables in effect as tests start"
set

%vmcmd% -Dosgi.os=%os% -Dosgi.ws=%ws% -Dosgi.arch=%arch% -jar eclipse\plugins\%launcher-jar% -data workspace -application org.eclipse.ant.core.antRunner -file test.xml %tests% -Dws=%ws% -Dos=%os% -Darch=%arch% -D%installmode%=true %properties% -logger org.apache.tools.ant.DefaultLogger

goto end

:end
