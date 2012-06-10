#!/usr/bin/env bash

#
#

DROP_ID=I20120608-1400
DL_LABEL=4.2RC4

BUILD_TIMESTAMP=${DROP_ID//[I-]/}
DL_DROP_ID=S-${DL_LABEL}-${BUILD_TIMESTAMP}

source updateIndexFilesFunction.sh

DL_SITE_PATH=/home/data/httpd/download.eclipse.org/eclipse/downloads/drops4/

cd /opt/public/eclipse/eclipse4I/siteDir/eclipse/downloads/drops4
echo "PWD: ${PWD}"
cp /opt/public/eclipse/sdk/renameBuild.sh .

echo "save temp backup copy to ${DROP_ID}ORIG"
rsync -ra ${DROP_ID}/ ${DROP_ID}ORIG

echo "rename ${DROP_ID} ${DL_DROP_ID} ${DL_LABEL}"
./renameBuild.sh ${DROP_ID} ${DL_DROP_ID} ${DL_LABEL}

echo "rsync ${DL_DROP_ID} to ${DL_SITE_PATH}"
rsync -r ${DL_DROP_ID} ${DL_SITE_PATH}

updateIndex 4

echo "move backup back to original"
mv ${DROP_ID}ORIG ${DROP_ID}

rm renameBuild.sh 
