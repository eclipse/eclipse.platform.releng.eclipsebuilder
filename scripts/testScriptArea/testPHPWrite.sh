
buildResults="/home/davidw/temp"
basebuilderBranch="abcd"
eclipsebuilderBranch="1234"

# make sure exists, before we write a file there
mkdir -p $buildResults
echo "<?php " > ${buildResults}/buildProperties.php
echo "\$basebuilderBranch='${basebuilderBranch}';" >> ${buildResults}/buildProperties.php
echo "\$eclipsebuilderBranch='${eclipsebuilderBranch}';" >> $buildResults/buildProperties.php
echo "?>" >> $buildResults/buildProperties.php