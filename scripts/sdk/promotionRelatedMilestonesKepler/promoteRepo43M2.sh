#!/usr/bin/env bash


DROP_SITE_ID=I20120920-1300

DL_SITE_ID=S-4.3M2-201209201300

BUILDMACHINE_BASE_SITE=/opt/public/eclipse/eclipse4I/siteDir/updates/4.3-I-builds

BUILDMACHINE_SITE=${BUILDMACHINE_BASE_SITE}/${DROP_SITE_ID}

DLMACHINE_BASE_SITE=/home/data/httpd/download.eclipse.org/eclipse/updates/4.3milestones

DLMACHINE_SITE=${DLMACHINE_BASE_SITE}/${DL_SITE_ID}

# remember, need trailing slash since going from existing directories 
# contents to new directories contents
rsync -r "${BUILDMACHINE_SITE}/"  "${DLMACHINE_SITE}"

echo " ... remember to update composite files and mirrors URL ... "

