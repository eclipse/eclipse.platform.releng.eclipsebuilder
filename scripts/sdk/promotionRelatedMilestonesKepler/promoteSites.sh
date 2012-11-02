
DROP_ID=I20121031-2000
DL_LABEL=4.3M3
DL_LABEL_EQ=KeplerM3

./promoteDropSiteEq.sh ${DROP_ID} ${DL_LABEL_EQ}
./promoteDropSite.sh   ${DROP_ID} ${DL_LABEL}
./promoteRepo.sh ${DROP_ID} ${DL_LABEL}
