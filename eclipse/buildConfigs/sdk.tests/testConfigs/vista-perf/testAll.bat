
REM run all tests.  -vm argument used as is to eclipse launcher for target eclipse
call runtests.bat -vm %cd%\..\jdk6_17\jre\bin\javaw -properties vm.properties "-Dtest.target=performance" "-Dplatform=win32perf2" 1> %2 2>&1
exit