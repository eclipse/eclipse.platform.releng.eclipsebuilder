#!/usr/bin/env bash

# This script should not be needed often, by itself, but might need
# for tests or to "fix" a repo that is bad.

source syncRepoSite.shsource

# needs eclipseStream and buildType as arguments

syncRepoSite $1 $2

