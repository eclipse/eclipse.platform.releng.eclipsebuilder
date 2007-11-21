@echo off

REM reset ant command line in environment and variables
set ws=win32
set installOs=win32
set arch=x86
set target=
set ANT_CMD_LINE_ARGS=
set bootclasspath=
set compiler=
set compilelibs=
set ANT_OPTS=-Xmx768m
if x%1==x goto usage

REM process all command line parameters
:loop
if x%1==x goto checkvars
if x%1==x-os set installOs=%2
if x%1==x-ws set ws=%2
if x%1==x-bc set bootclasspath="-Dbootclasspath=%2"
if x%1==x-compilelibs set compilelibs="-Dlibsconfig=true"
if x%1==x-target set target=%2
if x%1==x-arch set arch=%2
shift
goto loop

REM verify that ws and os values and combinations are valid
:checkvars
if x%installOs%==x goto usage
if x%ws%==x goto usage 
if x%arch%==x goto usage
if %installOs%-%ws%-%arch%==win32-win32-x86 goto run
if %installOs%-%ws%-%arch%==win32-wpf-x86 goto run
if %installOs%-%ws%-%arch%==win32-win32-ia64 goto run
if %installOs%-%ws%-%arch%==linux-motif-x86 goto run
if %installOs%-%ws%-%arch%==linux-gtk-x86 goto run
if %installOs%-%ws%-%arch%==linux-gtk-ppc goto run
if %installOs%-%ws%-%arch%==linux-gtk-x86_64 goto run
if %installOs%-%ws%-%arch%==linux-gtk-ia64 goto run
if %installOs%-%ws%-%arch%==linux-gtk-s390 goto run
if %installOs%-%ws%-%arch%==linux-gtk-s390x goto run
if %installOs%-%ws%-%arch%==solaris-motif-sparc goto run
if %installOs%-%ws%-%arch%==solaris-gtk-sparc goto run
if %installOs%-%ws%-%arch%==solaris-gtk-x86 goto run
if %installOs%-%ws%-%arch%==aix-motif-ppc goto run
if %installOs%-%ws%-%arch%==hpux-motif-PA_RISC goto run
if %installOs%-%ws%-%arch%==qnx-photon-x86 goto run
if %installOs%-%ws%-%arch%==hpux-motif-ia64_32 goto run
if %installOs%-%ws%-%arch%==macosx-carbon-ppc goto run

ECHO The ws os arch combination entered is not valid.
goto end

:usage
ECHO "usage %0 -os <osType> -ws <windowingSystem> -arch <architecture> [-bc bootclasspath]  [-compilelibs] [-target target]"
goto end

:run
set ORIGCLASSPATH=%CLASSPATH
call ant -q -buildfile jdtcoresrc/compilejdtcorewithjavac.xml
set CLASSPATH=jdtcoresrc/ecj.jar;%CLASSPATH
call ant -q -buildfile jdtcoresrc/compilejdtcore.xml
set CLASSPATH=ecj.jar;%ORIGCLASSPATH
ant -q -buildfile build.xml %target% -DinstallOs=%installOs% -DinstallWs=%ws% -DinstallArch=%arch% %compilelibs%  %bootclasspath% 
goto end

:end
