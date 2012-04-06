#!/usr/bin/env bash

# assumes master script in same (current) directory
export DEBUG=true; ./masterBuild.sh 2>&1 | tee fullmasterBuildOutput.txt
