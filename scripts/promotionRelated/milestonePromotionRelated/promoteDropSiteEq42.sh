#!/usr/bin/env bash

# note we use the "4.2 build", but label is "3.8"

DROP_ID=I20120524-2100
DL_LABEL=3.8RC2
DL_DROP_ID=S-${DL_LABEL}-201205242100

source createEquinoxPromotionScriptFunction.sh

cd /opt/public/eclipse/eclipse4I/siteDir/equinox/downloads/drops
echo "PWD: ${PWD}"
cp /opt/public/eclipse/sdk/renameBuild.sh .

echo "save temp backup copy to ${DROP_ID}ORIG"
rsync -ra ${DROP_ID}/ ${DROP_ID}ORIG

echo "rename ${DROP_ID} ${DL_DROP_ID} ${DL_LABEL}"
./renameBuild.sh ${DROP_ID} ${DL_DROP_ID} ${DL_LABEL}

echo "move backup back to original"
mv ${DROP_ID}ORIG ${DROP_ID}

rm renameBuild.sh 

createPromotionScriptEq ${DROP_ID}
