#!/usr/bin/env bash

# BUILD_ID is original I (or M) build on build machine that is being promoted
BUILD_ID=I20120608-1200
# $DL_LABEL takes form of 3.8M7, 3.8RC4, 3.8, etc.
DL_LABEL=3.8
# DROP_TYPE either S, R
DROP_TYPE=R

./promoteDropSite.sh ${BUILD_ID} ${DL_LABEL} ${DROP_TYPE}
