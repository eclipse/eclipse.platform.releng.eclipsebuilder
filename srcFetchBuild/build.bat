@echo off

REM reset ant command line in environment and variables
set ws=
set os=
set target=
set ANT_CMD_LINE_ARGS=
set bootclasspath=%JAVA_HOME%\jre\lib\rt.jar
set install=

if x%1==x goto usage

REM process all command line parameters
:loop
if x%1==x goto checkvars
if x%1==x-os set os=%2
if x%1==x-ws set ws=%2
if x%1==x-bc set bootclasspath=%2
if x%1==x-target set target=%2
if x%1==x-install set install=%2
shift
goto loop

REM verify that ws and os values and combinations are valid
:checkvars
if x%os%==x goto usage
if x%ws%==x goto usage 
if %os%-%ws%==win32-win32 goto run
if %os%-%ws%==linux-motif goto run
if %os%-%ws%==linux-gtk goto run
if %os%-%ws%==solaris-motif goto run
if %os%-%ws%==aix-motif goto run
if %os%-%ws%==hpux-motif goto run
if %os%-%ws%==qnx-photon goto run

ECHO The ws os combination entered is not valid.
goto end

:usage
ECHO "usage %0 -os <osType> -ws <windowingSystem> [-bc bootclasspath] [-target target] [-install install]"
goto end

:run
if x%install%==x goto rundefault
ant -buildfile build.xml %target% -Dinstall=%install% -Dos=%os% -Dws=%ws% -Dbootclasspath=%bootclasspath%
goto end

:rundefault
ant -buildfile build.xml %target% -Dos=%os% -Dws=%ws% -Dbootclasspath=%bootclasspath%
goto end

:end
