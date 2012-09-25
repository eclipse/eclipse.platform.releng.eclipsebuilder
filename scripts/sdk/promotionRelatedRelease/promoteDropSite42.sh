#!/usr/bin/env bash

# BUILD_ID is original I (or M) build on build machine that is being promoted
BUILD_ID=M20120914-1800
# DL_LABEL takes form of 4.2M7, 4.2RC4, 4.2, etc.
DL_LABEL=4.2.1
# DROP_TYPE either S, R
DROP_TYPE=R

./promoteDropSite.sh ${BUILD_ID} ${DL_LABEL} ${DROP_TYPE}
