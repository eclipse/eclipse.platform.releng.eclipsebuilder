#!/usr/bin/env bash

# directly gets a fresh copy of sdk directory from eclipsebuilder
# need to manually check and make sure nothing is running or will
# be running soon.

# codifying the branch (or tag) to use, so it can be set/chagned in one place
initScriptTag="h=master"

# to use a tag instead of branch, would be tag=X, such as
# tag=vI20120417-0700, or in full form
# http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/wgetFresh.sh?tag=vI20120417-0700

source /shared/eclipse/sdk/checkForErrorExit.sh

# make sure we start of in right directory
#cd /shared/eclipse/sdk
#checkForErrorExit $? "could cd to /shared/eclipse/sdk"

# first get a fresh copy of just this file, put in parent directory
# since overtime there will be few changes and can re-invoke from there.
#fileToGet=wgetFreshSDKdir.sh
#wget --no-verbose -O ../${fileToGet} http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/sdk/${fileToGet}?${initScriptTag}  2>&1
#checkForErrorExit $? "could not wget file: ${fileToGet}"
#chmod -c +x ../${fileToGet}
cd /shared/eclipse
checkForErrorExit $? "could not change directory up?!"

# remove if exists from previous (failed) run
rm -fr tempeb 2>/dev/null
mkdir -p tempeb
checkForErrorExit $? "could not mkdir?!"

wget -O master.zip http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/snapshot/master.zip
checkForErrorExit $? "could not get eclispebuilder?!"

unzip -q master.zip -d tempeb
checkForErrorExit $? "could not unzip master?!"

# save a copy to diff with (and revert to if needed)
rm -fr sdkTempSave 2>/dev/null
mv sdk sdkTempSave

rsync -r tempeb/master/scripts/sdk/ sdk

diff -r sdk sdkTempSave > sdkdiffout.txt

rm master.zip
rm -fr tempeb
