nbuilds=$( find /home/data/httpd/download.eclipse.org/eclipse/downloads/drops4 -maxdepth 1 -ctime +4 -name "N*" -exec echo '{}' \; | wc -l )
if [[ nbuilds > 4 ]] 
then
   echo "Number of builds before cleaning: $nbuilds"
   find /home/data/httpd/download.eclipse.org/eclipse/downloads/drops4 -maxdepth 1 -ctime +4 -name "N*" -exec echo '{}' \;
   find /home/data/httpd/download.eclipse.org/eclipse/downloads/drops4 -maxdepth 1 -ctime +4 -name "N*" -exec rm -fr '{}' \;
   nbuilds=$( find /home/data/httpd/download.eclipse.org/eclipse/downloads/drops4 -maxdepth 1 -ctime +4 -name "N*" -exec echo '{}' \; | wc -l )
   echo "Number of builds after cleaning: $nbuilds"
   /opt/public/eclipse/sdk/promotionRelatedRelease/updateIndexes.sh
else
   echo 
fi

# shared (build machine)
# can be aggressive in removing builds from "downloads", but not "updates"
find /opt/public/eclipse/eclipse4N/siteDir/eclipse/downloads/drops4 -maxdepth 1 -ctime +1 -name "N*" -exec echo '{}' \;
find /opt/public/eclipse/eclipse4N/siteDir/eclipse/downloads/drops4 -maxdepth 1 -ctime +1 -name "N*" -exec rm -fr '{}' \;

find /opt/public/eclipse/eclipse4N/siteDir/equinox/drops -maxdepth 1 -ctime +1 -name "N*" -exec echo '{}' \;
find /opt/public/eclipse/eclipse4N/siteDir/equinox/drops -maxdepth 1 -ctime +1 -name "N*" -exec rm -fr '{}' \;

# promotion scripts
find /opt/public/eclipse/sdk/promotion/queue -name "RAN*" -ctime +2 -exec echo '{}' \;
find /opt/public/eclipse/sdk/promotion/queue -name "RAN*" -ctime +2 -exec rm '{}' \;


# clean 4.x M builds
find /home/data/httpd/download.eclipse.org/eclipse/downloads/drops4 -maxdepth 1 -ctime +30 -name "M*" -exec echo '{}' \;
find /home/data/httpd/download.eclipse.org/eclipse/downloads/drops4 -maxdepth 1 -ctime +30 -name "M*" -exec rm -fr '{}' \;
# clean 3.x M builds
find /home/data/httpd/download.eclipse.org/eclipse/downloads/drops -maxdepth 1 -ctime +30 -name "M*" -exec echo '{}' \;
find /home/data/httpd/download.eclipse.org/eclipse/downloads/drops -maxdepth 1 -ctime +30 -name "M*" -exec rm -fr '{}' \;

/opt/public/eclipse/sdk/promotionRelatedRelease/updateIndexes.sh


