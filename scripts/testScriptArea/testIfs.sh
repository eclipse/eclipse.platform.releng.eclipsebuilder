
trExitCode=0
continueBuildOnNoChange=false

if [[  "${trExitCode}" == "59"   &&   "${continueBuildOnNoChange}" != "true"  ]]
then
    # TODO: eventually would be an email message sent here
    #    mailx -s "$eclipseStream SDK Build: $buildTag auto tagging failed. Build canceled." david_williams@us.ibm.com <<EOF
      echo "No changes detected by autotagging. Build halted."
      exit 1
else
    echo continue building
fi