eclipseStream=4.2
buildId=I2012
trExitCode=59
continueBuildOnNoChange=false
testbuildonly=true

if [[ ( "${trExitCode}" == "59" )  &&  ( "${continueBuildOnNoChange}" != "true" ) ]]
then 
    if [[ "${testbuildonly}" == "true" ]]  
    then
        # send mail only to testonly address
        toAddress=daddavidw@gmail.com
    else 
        # if not a test build, send "no change" mail to list
        #toAddress=platform-releng-dev@eclipse.org
        # interesting ... can not have "empty" else clauses
        toAddress=daddavidw@gmail.com
    fi  
    (   
    echo "From: e4Builder@eclipse.org"
    echo "To: ${toAddress}"
    echo "MIME-Version: 1.0"
    echo "Content-Type: text/plain; charset=utf-8"
    echo "Subject: $eclipseStream Build: $buildId canceled. No changes detected (eom)"
    echo ""
    ) | /usr/lib/sendmail -t

    echo "No changes detected by autotagging. Mail sent. Build halted." 
    exit 1
    # else continue building
fi
