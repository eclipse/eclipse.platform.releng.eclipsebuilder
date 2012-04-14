#!/usr/bin/env bash

# simply utility to show, and save current cronjobs
# 
# not a bad idea to save a complete copy before making
# changes

# assume ran from "current user id" and "current directory"

timestamp=$( date +%Y%m%d-%H%M )
outfilename=cronjobs-${timestamp}.txt
crontab -l | tee $outfilename
