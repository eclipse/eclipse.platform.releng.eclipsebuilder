#!/usr/bin/env bash

PROJECT=$1
if [ -z $PROJECT ]
then
    echo "must provide project name as first argumnet"
    exit 9;
fi
TODIR=$2
if [ -z $TODIR ]
then
    echo "must provide TODIR name as second argumnet"
    exit 8;
fi
DROPDIR=$3
if [ -z $DROPDIR ]
then
    echo "must provide DROPDIR name as third argumnet"
    exit 7;
fi

# ideally, the user executing this mail will have this special file in their home direcotry,
# that can specify a custom 'from' variable, but still you must use your "real" ID that is subscribed
# to the wtp-dev mailing list
#   set from="\"Your Friendly WTP Builder\" <real-subscribed-id@real.address>"
# correction ... doesn't work. Seems the subscription system set's the "from" name, so doesn't work when
# sent to mail list (just other email addresses)
export MAILRC=~/.buildermailrc

SUBJECT="Declaring Build for $PROJECT: $DROPDIR"

# wtp-dev for promotes, wtp-releng for smoketest requests
TO="wtp-dev@eclipse.org"

#make sure reply to goes back to the list
REPLYTO="wtp-dev@eclipse.org"
#we need to "fix up" TODIR since it's in file form, not URL
URLTODIR=${TODIR##*${DOWNLOAD_ROOT}}
mail -s "$SUBJECT" -R "$REPLYTO" "$TO"  <<EOF


Download Page:
http://download.eclipse.org$URLTODIR$DROPDIR

General Smoketest results page:
http://wiki.eclipse.org/WTP_Smoke_Test_Results

EOF

