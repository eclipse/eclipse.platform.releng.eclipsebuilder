#!/usr/bin/env bash

source syncDropLocation.shsource

source sendPromoteMail.shsource

syncDropLocation $1 $2 $3

rccode=$?

if [ $rccode -eq 0 ] 
then 

    sendPromoteMail $1 $2 $3

else 
    echo "ERROR occurred during promotion to download server, so did not send mail."
fi
