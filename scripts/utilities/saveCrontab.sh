#!/usr/bin/env bash

# simply utility to show, and save current cronjobs
# 
# not a bad idea to save a complete copy before making
# changes

# assume ran from "current user id" and "current directory"

timestamp=$( date +%Y%m%d-%H%M )
outfilename=crontab-${timestamp}.txt
crontab -l | tee $outfilename

printf "\n\tlisting of crontab saved to %s \n\n" ${outfilename}
