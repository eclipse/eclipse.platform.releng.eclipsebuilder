#!/usr/bin/env bash

# assumes master script in same (current) directory
DEBUG=true ./masterBuild.sh -buildType N -eclipseStream 4.2  2>&1 | tee fullmasterBuildOutput.txt
