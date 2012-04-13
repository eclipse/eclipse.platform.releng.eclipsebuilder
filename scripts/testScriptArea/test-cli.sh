#!/usr/bin/env bash

# small utilitity to confirm command line processing utility 
# is working as expected. 
# If changes to command line procedure are changed, then 
# this test should be changed as well

# The purpose is to make sure the "junk" values do show up 
# is the debug echos (if not, then something is probably misspelled, 
# or forgot to use conditional assignments. 

DEBUG=true VERBOSE_REMOVES=-v  ./processCommandLine.sh \
    -buildType Njunk \
    -eclipseStream 4.2junk \
    -relengBranch rbjunk \
    -eclipseStream esJunk \
    -buildType btJunk \
    -gitCache gcJunk \
    -relengMapsProject rmpJunk \
    -relengRepoName rpNameJunk \
    -buildRoot buildRootJunk \
    -gitEmail gemJunk \
    -gitName gnameJunk \
    -basebuilderBranch bbJunk \
    -eclipsebuilderBranch ebbJunk \
    -timestamp tsJunkdateandtime \
    2>&1 | tee fullmasterBuildOutput.txt

    # call with no arguments specified, 
    # to confirm reasonable defaults are assigned. 
DEBUG=true  ./processCommandLine.sh \
       2>&1 | tee fullmasterBuildOutput.txt

        