@echo off
REM This script requires that contents of the org.eclipse.releng.basebuilder project are copied into this project

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

REM Value for the buildid property.
set buildid=""

REM The value of the buildLabel property, the name of the directory containing the products of the build
set buildLabel=""

REM The value for the mapVersionTag property.  Used to checkout the .map file project using the value set here.
set mapVersionTag=HEAD

REM the value for the buildDirectory property.
REM This is the directory relative to builddir where features and plugins will be compiled
set buildDirectory=src

REM The default value for the buildtype property.  Determines whether map file tags are used as entered or are replaced with HEAD
set buildType=I

REM The default value for the postingDirectory property.  This is the directory where to copy build.
set postingDirectory=.


REM process all command line parameters
:loop
if x%1==x goto checkvars
if x%1==x-? goto usage
if x%1==x-mail set mail="" && goto checkMailProperties
if x%1==x-buildid set buildid=%2
if x%1==x-bootclasspath set bootclasspath=%2
if x%1==x-buildLabel set buildLabel=%2
if x%1==x-postingDirectory set postingDirectory=%2
if x%1==x-mapVersionTag set mapVersionTag=%2
if x%1==x-buildType set buildType=%2

shift
goto loop

goto checkvars

goto end
REM  verify that a monitor.properties file exists with host, sender and recipients information for sending notification that build has started.
:checkMailProperties
if NOT EXIST monitor.properties echo A monitor.properties file will be required in this directory in order to send email notification that build has started.  Please see instructions.
goto end

:checkvars
REM  Set default buildid and buildLabel if none explicitly set
if %buildid% == "" set buildid=%buildType%%builddate%
if %buildLabel% == "" set buildLabel=%buildType%-%buildid%-%timestamp%

REM verify existance of rt.jar, javadoc tool and JAVA_HOME environment variable settings.
if x%JAVA_HOME%=="x%JAVA_HOME%" echo The JAVA_HOME environment variable has not been set && goto end
if NOT EXIST %bootclasspath% echo rt.jar does not exist at this location: %bootclasspath%. Please verify your bootclasspath setting. && goto end
if NOT EXIST %JAVADOC14_HOME%\javadoc.exe echo javadoc.exe not found in %JAVADOC14_HOME%.  Please verify your JAVA_HOME setting. && goto end
goto run


REM run the build.  Command to invoke the Eclipse AntRunner headless.
:run
java -cp startup.jar org.eclipse.core.launcher.Main -os win32 -ws win32 -arch x86 -noupdate -application org.eclipse.ant.core.antRunner -buildfile build.xml %mail% -Dinstall=%buildDirectory% -DbuildDirectory=%buildDirectory% -DpostingDirectory=%postingDirectory% -Drt=%bootclasspath% -Dbootclasspath=%bootclasspath% -DbuildType=%buildType% -D%buildType%=true -Dbuildid=%buildid% -DbuildLabel=%buildLabel% -Dtimestamp=%timestamp% -DJAVADOC14_HOME=%javadoc14_home% -DmapVersionTag=%mapVersionTag% "-DzipArgs= "

:usage
echo "usage: %0 [-mail][-buildid name][-buildLabel directory][-postingDirectory directory][-mapVersionTag tag][-bootclasspath path] M|N|I|S|R"

:end
pause