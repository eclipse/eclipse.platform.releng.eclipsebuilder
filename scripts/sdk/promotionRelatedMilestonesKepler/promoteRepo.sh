#!/usr/bin/env bash

DROP_SITE_ID=$1 
DL_LABEL=$2 

function usage ()
{
    printf "\n\tUsage: %s DROP_SITE_ID DL_LABEL " $(basename $0) >&2
    printf "\n\t\t%s\t%s" "DROP_SITE_ID " "such as I20121031-2000." >&2 
    printf "\n\t\t%s\t%s" "DL_LABEL " "such as 4.3M3." >&2 
}

if [[ -z "${DROP_SITE_ID}" || -z "${DL_LABEL}" ]]
then
    echo "ERROR: arguments missing in call to $( basename $0 )"
    usage
    exit 1
fi

DL_TYPE=S
BUILD_TIMESTAMP=${DROP_SITE_ID//[MI-]/}
DL_SITE_ID=${DL_TYPE}-${DL_LABEL}-${BUILD_TIMESTAMP}

BUILDMACHINE_BASE_SITE=/opt/public/eclipse/eclipse4I/siteDir/updates/4.3-I-builds

BUILDMACHINE_SITE=${BUILDMACHINE_BASE_SITE}/${DROP_SITE_ID}

DLMACHINE_BASE_SITE=/home/data/httpd/download.eclipse.org/eclipse/updates/4.3milestones

DLMACHINE_SITE=${DLMACHINE_BASE_SITE}/${DL_SITE_ID}

# remember, need trailing slash since going from existing directories
# contents to new directories contents
rsync -r "${BUILDMACHINE_SITE}/"  "${DLMACHINE_SITE}"

# TODO: automate this
echo " ... remember to update composite files and mirrors URL ... "

