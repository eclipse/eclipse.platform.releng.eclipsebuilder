#!/usr/bin/env bash

# assumes master script in same (current) directory
./masterBuild.sh 2>&1 | tee fullmasterBuildOutput.txt
