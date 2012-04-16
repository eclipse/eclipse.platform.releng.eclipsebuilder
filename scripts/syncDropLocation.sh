#!/usr/bin/env bash

# this is the single script to call that "does it all" to promote build 
# to update site, drop site, update index page on downlaods, and send mail to list.

# it requires three arguments
#    eclipseStream (e.g. 4.2 or 3.8) 
#    buildType     (e.g. I or N) 
#    buildId       (e.g. N20120415-2015)

    eclipseStream=$1
    if [ -z "${eclipseStream}" ]
    then
       echo "must provide eclispeStream as first argumnet, for this function $0"
       return 1;
    fi


    buildType=$2
    if [ -z "${buildType}" ]
    then
        echo "must provide buildType as second argumnet, for this function $0"
        return 1;
    fi
 
    buildId=$3
    if [ -z "${buildId}" ]
    then
         echo "must provide buildId as third argumnet, for this function $0"
         return 1;
    fi



source syncRepoSite.shsource

source syncDropLocation.shsource

source sendPromoteMail.shsource

syncRepoSite $1 $2

rccode=$?

if [ $rccode -ne 0 ] 
then 
    echo "ERROR: something went wrong putting repo on download site. Rest of promoting build halted."
    exit 1
fi


syncDropLocation $1 $2 $3

rccode=$?

if [ $rccode -ne 0 ] 
then 
    echo "ERROR occurred during promotion to download server, so halted promotion and did not send mail."
    exit 1
fi 

sendPromoteMail $1 $2 $3

rccode=$?

if [ $rccode -ne 0 ] 
then 
    echo "ERROR occurred during sending final mail to list"
    exit 1
fi 

exit 0
