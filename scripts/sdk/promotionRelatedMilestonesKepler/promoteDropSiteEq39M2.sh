#!/usr/bin/env bash

DROP_ID=I20120920-1300
DL_LABEL=3.9M2
DL_DROP_ID=S-${DL_LABEL}-201209201300

cd /opt/public/eclipse/eclipse4I/siteDir/equinox/drops
cp /opt/public/eclipse/sdk/renameBuild.sh .

rsync -ra ${DROP_ID}/ ${DROP_ID}ORIG

./renameBuild.sh ${DROP_ID} ${DL_DROP_ID} ${DL_LABEL}

mv ${DROP_ID}ORIG ${DROP_ID}

rm renameBuild.sh

echo "rsync -r /opt/public/eclipse/eclipse4I/siteDir/equinox/drops/${DL_DROP_ID} /home/data/httpd/download.eclipse.org/equinox/downloads/drops/" \
     > /opt/public/eclipse/equinox/promotion/queue/promote-${DL_LABEL}.sh

chmod +x /opt/public/eclipse/equinox/promotion/queue/promote-${DL_LABEL}.sh



