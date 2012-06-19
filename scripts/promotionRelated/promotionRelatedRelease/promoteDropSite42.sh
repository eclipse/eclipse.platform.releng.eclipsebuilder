#!/usr/bin/env bash

# BUILD_ID is original I (or M) build on build machine that is being promoted
BUILD_ID=I20120608-1400
# DL_LABEL takes form of 4.2M7, 4.2RC4, 4.2, etc.
DL_LABEL=4.2
# DROP_TYPE either S, R
DROP_TYPE=R

./promoteToDropSite ${BUILD_ID} ${DL_LABEL} ${DROP_TYPE}
