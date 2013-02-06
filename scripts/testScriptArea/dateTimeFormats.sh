#!/usr/bin/env bash

# since I always forget, some of my favorite "date formats"

# timestamps, year, month, day, hour, minute
# (sorts well, since "least changed" is towards the left).
timestamp=$( date +%Y%m%d%H%M )

echo $timestamp

#some like hyphens before time
timestamp=$( date +%Y%m%d-%H%M )

echo $timestamp


START_TIME=`date +%s`
sleep 62
END_TIME=`date +%s`
ELAPSED=$((END_TIME-START_TIME))
echo "Raw Elapsed: $ELAPSED"
echo "FINISHED at " `date` " Elapsed time: " `date -d 00:00:$ELAPSED +%H:%M:%S`

printf "Pretty format Elapsed Time: %02d:%02d:%02d:%02d\n" "$((ELAPSED/86400))" "$(($ELAPSED/3600%24))" "$(($ELAPSED/60%60))" "$(($ELAPSED%60))"


RAWDATE=$( date +%s )
sleep 5
timestamp=$( date +%Y%m%d-%H%M --date='@'$RAWDATE )
sleep 5
prettyDate=$( date --date='@'$RAWDATE )

