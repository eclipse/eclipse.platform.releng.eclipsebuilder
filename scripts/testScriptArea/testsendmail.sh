reporttext=$( cat /opt/public/eclipse/eclipse4I/siteDir/eclipse/downloads/drops4/I20120416-2327/report.txt) 
# test value, initially
toAddress=daddavidw@gmail.com
#toAddress=platform-releng-dev@eclipse.org
eclipseStream=4.2
buildId=I2012

# probably do not need "reply-to" if sent to mailing list 
# (the list itself will be reply-to address automatically) 
# but ... if needed ... something like this would work
# echo "Reply-to: daddavidw@gmail.com"

(
echo "From: e4Builder@eclipse.org"
echo "To: ${toAddress}"
echo "MIME-Version: 1.0"
echo "Content-Type: text/plain; charset=utf-8"
echo "Subject: $eclipseStream Build: $buildId started"
echo " "
echo $eclipseStream Build: $buildId started"
echo " " 
echo "$reporttext" 
echo " "
) | /usr/lib/sendmail -t
