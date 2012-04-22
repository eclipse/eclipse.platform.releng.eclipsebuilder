#!/usr/bin/env bash

# cron job a committer can run, 
# say, every 15 minutes, or similar. If a
# promotion script appears in the promoteLocation, then execute it, and if all goes
# well, then remove (or move) that promotion script.   

# Note: if there are errors that occur during this cron job, they go to the 
# "default user" for that crontab, which may be what's desired, but you can also 
# set MAILTO in your crontab, cautiously, to send it where ever you'd like. 

# TODO: currently we will count on the promote script 
# finishing before the cron job runs again. But 
# would be better to write a lock file, which, if found, 
# would indicate to the cron job to not do anything 
# (maybe return a warning). 

# TODO: we could "loop" if we found more than one ... if we ever 
# thought we'd be producing that many files ... but, for now, 
# assuming there is like one, two, or three per day.

# The 'workLocation' provides a handy central place to have the 
# promote script, and log results. ASSUMING this works for all 
# types of builds, etc (which is the goal for the sdk promotions).
workLocation=/shared/eclipse/sdk/promotion

# masterBuilder.sh must know about and use this same 
# location to put its promotions scripts. (i.e. implicite tight coupling)
promoteScriptLocationEclipse=$workLocation/queue

# we redirect "find" std err to nowhere, else "not finding something" is reported 
# on "standard err" (which isn't very interesting).
promotefile=$( find $promoteScriptLocationEclipse -name "promote*.sh" | sort | head -1 )  

echo $promotefile

if [[ -z "$promotefile" ]] 
then
    # nothing to do, exit zero
    exit 0
else 
    # found a file, make sure it is executable
    if [[ -x $promotefile ]]
    then 

        # notice these are concatenated on purpose, to give some "history", but
        # that means has to be "manually" removed every now and then. 
        # /bin/bash $promotefile 1>>$workLocation/promotion-out.txt
        # 2>>$workLocation/promotion-err.txt
        echo "DEBUG: normally would execute file here: $promotefile" 1>>$workLocation/promotion-out.txt 2>>$workLocation/promotion-err.txt
        rccode=$?
        if [[ $rccode != 0 ]]
        then 
            echo "ERROR: promotion returned an error: $rccode" 
            echo "       promotefile: $promotefile"
            exit 1
        else
            # all is ok, we'll remove the file so we won't execute it again. 
            # (we'll move for now, for later inspection, if things go wrong, but eventually can just rm them)
            mv $promotefile $promoteScriptLocationEclipse/RAN_$(basename $promotefile)
            exit 0
        fi
    else
        echo "WARNING: promotion file found, but was not executable"
        echo "         promoitefile: $promotefile"
        exit 1
    fi
fi
