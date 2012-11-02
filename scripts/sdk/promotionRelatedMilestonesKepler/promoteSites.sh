#!/usr/bin/env bash

DROP_ID=I20121031-2000
DL_LABEL=4.3M3
DL_LABEL_EQ=KeplerM3

./promoteDropSiteEq.sh ${DROP_ID} ${DL_LABEL_EQ}
rccode=$?
if [[ $rccode != 0 ]]
then
    printf "\n\n\t%s\n\n" "ERROR: promoteDropSiteEq.sh failed. Subsequent promotion cancelled."
    exit 1
fi

./promoteDropSite.sh   ${DROP_ID} ${DL_LABEL}
if [[ $rccode != 0 ]]
then
    printf "\n\n\t%s\n\n" "ERROR: promoteDropSite.sh failed. Subsequent promotion cancelled."
    exit 1
fi


./promoteRepo.sh ${DROP_ID} ${DL_LABEL}
if [[ $rccode != 0 ]]
then
    printf "\n\n\t%s\n\n" "ERROR: promoteRepo.sh failed."
    exit 1
fi

