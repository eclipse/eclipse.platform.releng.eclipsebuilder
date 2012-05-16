#!/usr/bin/env bash

# gets a fresh copy of many of the primary/working scripts needed in buildRoot
# not all are needed, so may change over time, but erring on the side of 
# over inclusion. 

# codifying the branch (or tag) to use, so it can be set/chagned in one place
initScriptTag=master

# tags: 
# http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/wgetFresh.sh?tag=vI20120417-0700


# to build, all that's needed is the appropriate mbNX.sh scripts. It gets what ever 
# else it needs. 

wget --no-verbose -O mb3I.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/mb3I.sh?h=$initScriptTag 2>&1;
wget --no-verbose -O mb4I.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/mb4I.sh?h=$initScriptTag 2>&1;
wget --no-verbose -O mb4N.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/mb4N.sh?h=$initScriptTag 2>&1;


# handy script to "wrap" a normal build script such as mb4I.sh to set global test/debug settings
wget --no-verbose -O testBuild.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/testBuild.sh?h=$initScriptTag 2>&1;

# get this script itself (would have to run twice to make use changes, naturally)
# and has trouble "writing over itself" so we put in a file with 'NEW' suffix
# but will remove it if no differences found.
# and a command line like the following works well

wget --no-verbose -O wgetFresh.NEW.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/wgetFresh.sh?h=$initScriptTag 2>&1;

differs=`diff wgetFresh.NEW.sh wgetFresh.sh`
echo "differs: ${differs}"
if [ -z "${differs}" ]
then 
    # 'new' not different from existing, so remove 'new' one
    rm wgetFresh.NEW.sh
else
    echo " " 
    echo "     wgetFresh.sh has changed. Compare with and consider replacing with wgetFresh.NEW.sh"
    echo "  "
fi

chmod +x *.sh
