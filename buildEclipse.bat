@echo off
REM This script requires that contents of the org.eclipse.releng.basebuilder project are copied into this project

REM this environment variable required by CVS client
set HOME=c:

set usage="usage: %0 [-mail][-buildid name][-buildLabel directory][-postingDirectory directory][-mapVersionTag tag][-bootclasspath path] [-buildType M|N|I|S|R]"

REM  Create the date and time elements.
For /f "tokens=1-7 delims=:/-, " %%i in ('echo exit^|cmd /q /k"prompt $D $T"') do (
	For /f "tokens=2-4 delims=/-,() skip=1" %%a in ('echo.^|date') do (
		set dow=%%i
		set %%a=%%j
		set %%b=%%k
		set %%c=%%l
		set hh=%%m
		set min=%%n
		set ss=%%o
	)
)
set builddate=%yy%%mm%%dd%
set timestamp=%builddate%%hh%%min%

REM Ant property values

REM default value of the bootclasspath property used in Ant javac calls.  Value duplicated in rt property
set bootclasspath=%JAVA_HOME%\jre\lib\rt.jar

REM default value of the JAVADOC14_HOME property used for generating javadoc.
REM This is the directory containing 1.4 version of javadoc tool.  Defaults to currently installed JDK.
set JAVADOC14_HOME=%JAVA_HOME%\bin

REM flag indicating whether or not mail should be sent to indicate build has started
set mail="-DnoMail=true"

REM The value for the mapVersionTag property.  Used to checkout the .map file project using the value set here.
set mapVersionTag=HEAD

REM the value for the buildDirectory property.
REM This is the directory relative to builddir where features and plugins will be compiled
set buildDirectory=src

REM The default value for the buildtype property.  Determines whether map file tags are used as entered or are replaced with HEAD
set buildType=I

REM The default value for the buildtype property.  Determines whether map file tags are used as entered or are replaced with HEAD
set "buildid= "

REM The default value for the buildtype property.  Determines whether map file tags are used as entered or are replaced with HEAD
set "buildLabel= "

REM The default value for the postingDirectory property.  This is the directory where to copy build.
set postingDirectory=.


REM process all command line parameters
:loop
if x%1==x goto checkvars
if x%1==x-? echo %usage% && goto end
if x%1==x-mail set "mail= " && goto checkMailProperties
if x%1==x-buildid set "buildid=%2" && goto shift
if x%1==x-bootclasspath set bootclasspath=%2 && goto shift
if x%1==x-buildLabel set buildLabel=%2 && goto shift
if x%1==x-postingDirectory set postingDirectory=%2 && goto shift
if x%1==x-mapVersionTag set mapVersionTag=%2 && goto shift
if x%1==x-buildType set "buildType=%2" && goto shift

if NOT x%1==x echo %usage% && goto end
:shift
shift && shift && goto loop

REM  verify that a monitor.properties file exists with host, sender and recipients information for sending notification that build has started.
:checkMailProperties
if NOT EXIST monitor.properties echo A monitor.properties file will be required in this directory in order to send email notification that build has started.  Please see instructions.
shift && goto loop

:checkvars

REM  Set default buildid and buildLabel if none explicitly set
if x%buildid%==x set buildid=%buildType%%builddate%
if x%buildLabel%==x set buildLabel=%buildType%-%buildid%-%timestamp%

REM verify buildType setting
if x%buildType%==x echo %usage% && goto end

REM verify existance of rt.jar, javadoc tool and JAVA_HOME environment variable settings.
if x%JAVA_HOME%==x echo The JAVA_HOME environment variable has not been set.  See System Requirements in eclipsebuilder_readme.html. && goto end
if NOT EXIST %bootclasspath% echo rt.jar does not exist at this location: %bootclasspath%. See System Requirements in eclipsebuilder_readme.html. && goto end
if NOT EXIST %JAVADOC14_HOME%\javadoc.exe echo javadoc.exe not found in %JAVADOC14_HOME%.  See System Requirements in eclipsebuilder_readme.html. && goto end

REM start the build if above variables set
goto run


REM run the build.  Command to invoke the Eclipse AntRunner headless.
:run

java -cp startup.jar org.eclipse.core.launcher.Main -os win32 -ws win32 -arch x86 -noupdate -application org.eclipse.ant.core.antRunner -buildfile build.xml %mail% -Dinstall=%buildDirectory% -DbuildDirectory=%buildDirectory% -DpostingDirectory=%postingDirectory% -Drt=%bootclasspath% -Dbootclasspath=%bootclasspath% -DbuildType=%buildType% "-D%buildType%=true" -Dbuildid=%buildid% -DbuildLabel=%buildLabel% -Dtimestamp=%timestamp% -DJAVADOC14_HOME=%javadoc14_home% -DmapVersionTag=%mapVersionTag% "-DzipArgs= "

:end
pause