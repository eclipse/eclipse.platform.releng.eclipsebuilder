#!/usr/bin/env bash

DROP_ID=I20120920-1300
DL_LABEL=4.3M2
DL_DROP_ID=S-${DL_LABEL}-201209201300

cd /opt/public/eclipse/eclipse4I/siteDir/eclipse/downloads/drops4
cp /opt/public/eclipse/sdk/renameBuild.sh .

rsync -ra ${DROP_ID}/ ${DROP_ID}ORIG

./renameBuild.sh ${DROP_ID} ${DL_DROP_ID} ${DL_LABEL}

mv ${DROP_ID}ORIG ${DROP_ID}

rm renameBuild.sh 

rsync -r ${DL_DROP_ID} /home/data/httpd/download.eclipse.org/eclipse/downloads/drops4/

# php eclipse3x.php > eclipse3x.html

    wget -O index.txt http://download.eclipse.org/eclipse/downloads/createIndex4x.php
    rccode=$?
    if [ $rccode -eq 0 ]
    then
        rsync index.txt /home/data/httpd/download.eclipse.org/eclipse/downloads/index.html
        rccode=$?
        if [ $rccode -eq 0 ] 
        then
            echo "INFO: Upated http://download.eclipse.org/eclipse/downloads/index.html"
            return 0
        else
            echo "ERROR: Could not copy index.html to downlaods. rccode: $rccode"
            return $rccode
        fi
    else
        echo "ERROR: Could not create index.html from downlaods. rccode: $rccode"
        return $rccode
    fi

rm index.txt

