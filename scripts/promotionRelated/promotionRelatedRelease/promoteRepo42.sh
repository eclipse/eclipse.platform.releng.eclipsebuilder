#!/usr/bin/env bash

BUILD_ID=I20120608-1400
# DL_LABEL takes form of 3.8M7, 3.8RC4, 3.8, etc.
DL_LABEL=4.2
# DROP_TYPE either S, R
DROP_TYPE=R

./promoteRepo.sh ${BUILD_ID} ${DL_LABEL} ${DROP_TYPE}