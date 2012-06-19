#!/usr/bin/env bash

DROP_ID=I20120608-1200
DL_LABEL=3.8
BUILD_TIMESTAMP=${DROP_ID//[I-]/}

# Note 'R' for Release
DL_DROP_ID=R-${DL_LABEL}-${BUILD_TIMESTAMP}

source updateIndexFilesFunction.sh

DL_SITE_PATH=/home/data/httpd/download.eclipse.org/eclipse/downloads/drops/

cd /opt/public/eclipse/eclipse3I/siteDir/eclipse/downloads/drops
echo "PWD: ${PWD}"
cp /opt/public/eclipse/sdk/renameBuild.sh .

echo "save temp backup copy to ${DROP_ID}ORIG"
rsync -ra ${DROP_ID}/ ${DROP_ID}ORIG

echo "rename ${DROP_ID} ${DL_DROP_ID} ${DL_LABEL}"
./renameBuild.sh ${DROP_ID} ${DL_DROP_ID} ${DL_LABEL}
touch ${DL_DROP_ID}/buildHidden

echo "rsync ${DL_DROP_ID} to ${DL_SITE_PATH}"
rsync -r ${DL_DROP_ID} ${DL_SITE_PATH}

# no update of index, with "buildHidden" file in place, should not show up
#updateIndex 3

echo "move backup back to original"
mv ${DROP_ID}ORIG ${DROP_ID}

rm renameBuild.sh 

