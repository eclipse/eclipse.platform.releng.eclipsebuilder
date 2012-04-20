#!/usr/bin/env bash
# Under development. 

# First draft of a potential cron job a committer can run, 
# say, every 10 minutes, or similar, and if a
# promote script appears, then execute it, and if all goes
# well, then remove (or move) that promote file.   

# TODO: currently we will count on the promote script 
# finishing before the cron job runs again. But 
# would be better to write a lock file, which, if found, 
# would indicate to the cron job to not do anything 
# (maybe return a warning). 

# TODO: we could "loop" if we found more than one ... if we ever 
# thought we'd be producing that many files ... but, for now, 
# assuming there is like one, two, or three per day.

promoteLocation=/home/shared/eclipse/sdk/queue

promotefile=$( find $promoteLocation/promote*\.sh | sort | head -1 )  

echo $promotefile

if [[ -z "$promotefile" ]] 
then
    # nothing to do, exit zero
    exit 0
else 
    # found a file, make sure it is executable
    if [[ -x $promotefile ]]
    then 

        #/bin/bash $promotefile
        echo "DEBUG: normally would execute file here: $promotefile"
        rccode=$?
        if [[ $rccode != 0 ]]
        then 
            echo "ERROR: promotion returned and error: $rccode" 
            echo "       promotefile: $promotefile"
            exit 1
        else
            # all is ok, we'll remove the file so we won't execute it again. 
            # (we'll move for now, for inspection)
            mv $promotefile $promoteLocation/RAN_$(basename $promotefile)
            exit 0
        fi
    else
        echo "ERROR: promotion file found, but was not executable"
        echo "       promoitefile: $promotefile"
        exit 1
    fi
fi
# we exit here if nothing is found
