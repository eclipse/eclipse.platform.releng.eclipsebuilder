#!/bin/bash
# User specific environment and startup programs
umask 002

BASE_PATH=.:/bin:/usr/bin:/usr/bin/X11:/usr/local/bin:/usr/bin:/usr/X11R6/bin
LD_LIBRARY_PATH=.
BASH_ENV=$HOME/.bashrc
USERNAME=`whoami`
xhost +$HOSTNAME
DISPLAY=:0.0
CVS_RSH=ssh
ulimit -c unlimited
export CVS_RSH USERNAME BASH_ENV LD_LIBRARY_PATH DISPLAY

proc=$$

#notification list
recipients=

#default text message notification list
textRecipients=

#sets skip.performance.tests Ant property
skipPerf=""

#sets skipPack Ant property
skipPack=""

#sets skip.tests Ant property
skipTest=""

#sets sign Ant property
sign=""

tagMaps=""

#sets fetchTag="HEAD" for nightly builds if required
tag=""

# tag v20060907 is the one that includes the new build page
#buildProjectTags=v20080214a
buildProjectTags=v20080215

#updateSite property setting
updateSite=""

#flag indicating whether or not mail should be sent to indicate build has started
mail=""

#flag used to build based on changes in map files
compareMaps=""

#buildId - build name
buildId=""

#buildLabel - name parsed in php scripts <buildType>-<buildId>-<datestamp>
buildLabel=""

# tag for build contribution project containing .map files
mapVersionTag=HEAD

# directory in which to export builder projects
builderDir=/builds/eclipsebuilder

# buildtype determines whether map file tags are used as entered or are replaced with HEAD
buildType=N

# directory where to copy build
postingDirectory=/builds/transfer/files/master/downloads/drops

#directory for rss feed - not used 
#rssDirectory=/builds/transfer/files/master

# flag to indicate if test build
testBuild=""

# path to javadoc executable
javadoc=""

# value used in buildLabel and for text replacement in index.php template file
builddate=`date +%Y%m%d`
buildtime=`date +%H%M`
timestamp=$builddate$buildtime


# process command line arguments
usage="usage: $0 [-notify emailaddresses][-textRecipients textaddesses][-test][-buildDirectory directory][-buildId name][-buildLabel directory name][-tagMapFiles][-mapVersionTag tag][-builderTag tag][-bootclasspath path][-compareMaps][-skipPerf] [-skipTest] [-skipRSS] [-updateSite site][-skipPack][-sign] M|N|I|S|R"

if [ $# -lt 1 ]
then
		 		  echo >&2 "$usage"
		 		  exit 1
fi

while [ $# -gt 0 ]
do
		 		  case "$1" in
		 		  		 		  -buildId) buildId="$2"; shift;;
		 		  		 		  -buildLabel) buildLabel="$2"; shift;;
		 		  		 		  -mapVersionTag) mapVersionTag="$2"; shift;;
		 		  		 		  -tagMapFiles) tagMaps="-DtagMaps=true";;
		 		  		 		  -skipPerf) skipPerf="-Dskip.performance.tests=true";;
		 		  		 		  -skipTest) skipTest="-Dskip.tests=true";;
		 		  		 		  -skipRSS) skipRSS="-Dskip.feed=true";;
		 		  		 		  -skipPack) skipPack="-DskipPack=true";;
		 		  		 		  -buildDirectory) builderDir="$2"; shift;;
		 		  		 		  -notify) recipients="$2"; shift;;
		 		 		 		  -textRecipients) textRecipients="$2"; shift;;
		 		  		 		  -test) postingDirectory="/builds/transfer/files/bogus/downloads/drops";testBuild="-Dtest=true";;
		 		  		 		  -builderTag) buildProjectTags="$2"; shift;;
		 		  		 		  -compareMaps) compareMaps="-DcompareMaps=true";;
		 		  		 		  -updateSite) updateSite="-DupdateSite=$2";shift;;
		 		  		 		  -sign) sign="-Dsign=true";;
		 		  		 		  -*)
		 		  		 		  		 		  echo >&2 $usage
		 		  		 		  		 		  exit 1;;
		 		  		 		  *) break;;		 		  # terminate while loop
		 		  esac
		 		  shift
done

# After the above the build type is left in $1.
buildType=$1

# Set default buildId and buildLabel if none explicitly set
if [ "$buildId" = "" ]
then
		 		  buildId=$buildType$builddate-$buildtime
fi

if [ "$buildLabel" = "" ]
then
		 		  buildLabel=$buildId
fi

#Set the tag to HEAD for Nightly builds
if [ "$buildType" = "N" ]
then
        tag="-DfetchTag=HEAD"
        versionQualifier="-DforceContextQualifier=$buildId"
fi

# tag for eclipseInternalBuildTools on ottcvs1
internalToolsTag=$buildProjectTags

# tag for exporting org.eclipse.releng.basebuilder
baseBuilderTag=$buildProjectTags

# tag for exporting the custom builder
customBuilderTag=$buildProjectTags
#customBuilderTag=v20071213

if [ -e $builderDir ]
then
		 		  builderDir=$builderDir$timestamp
fi

# directory where features and plugins will be compiled
buildDirectory=$builderDir/src

mkdir $builderDir
cd $builderDir

#check out org.eclipse.releng.basebuilder
cvs -d sdimitro@dev.eclipse.org:/cvsroot/eclipse co -r $baseBuilderTag org.eclipse.releng.basebuilder
if [ "$tagMaps" == "-DtagMaps=true" ]; then  
  cvs -d sdimitro@dev.eclipse.org:/cvsroot/eclipse rtag -r $baseBuilderTag v$buildId org.eclipse.releng.basebuilder;
fi

#check out org.eclipse.releng.eclipsebuilder
cvs -d sdimitro@dev.eclipse.org:/cvsroot/eclipse co -r $customBuilderTag org.eclipse.releng.eclipsebuilder
if [ "$tagMaps" == "-DtagMaps=true" ]; then  
  cvs -d sdimitro@dev.eclipse.org:/cvsroot/eclipse rtag -r $customBuilderTag v$buildId  org.eclipse.releng.eclipsebuilder;
fi

#check out eclipseInternalBuildTools and install custom plugins
cvs -d sdimitro@ottcvs1:/home/cvs/releng co -r $internalToolsTag eclipseInternalBuildTools
if [ "$tagMaps" == "-DtagMaps=true" ]; then  
  cvs -d sdimitro@ottcvs1:/home/cvs/releng rtag -r $internalToolsTag v$buildId eclipseInternalBuildTools;
fi
cp -r eclipseInternalBuildTools/plugins org.eclipse.releng.basebuilder

#The URLs and filenames of vms used in build
linuxJdkArchive=jdks/jdk-1_5_0_14-fcs-bin-b03-linux-i586-05_oct_2007.zip
linuxppcJdkArchive=jdks/IBMJava2-SDK-1.4.2-10.0.ppc.tgz
linuxppcJdkArchive15=jdks/ibm-java2-sdk-5.0-6.0-linux-ppc.tgz
windowsJreArchive=jdks/jdk-1_4_2_16-fcs-bin-b05-windows-i586-16_sep_2007.zip
windows15JdkArchive=jdks/jdk-1_5_0_14-fcs-bin-b03-windows-i586-05_oct_2007.zip
windows16JdkArchive=jdks/1.6/jdk-6u4-fcs-bin-b12-windows-i586-14_dec_2007.zip
windows10FoundationArchive=jdks/weme-win-x86-foundation10_6.1.0.20060317-111429.zip

#get then install the Linux vm used for running the build
mkdir -p jdk/linux; cvs -d :pserver:anonymous@ottcvs1:/home/cvs/releng co $linuxJdkArchive; unzip -qq $linuxJdkArchive -d jdk/linux; rm $linuxJdkArchive

#get the install the Windows jre containing the Java libraries against which to compile
mkdir -p jdk/win32; cvs -d :pserver:anonymous@ottcvs1:/home/cvs/releng co $windowsJreArchive;unzip -qq $windowsJreArchive -d jdk/win32; rm $windowsJreArchive

#get and install the Windows 1.5 jre containing the 1.5 Java libraries against which to compile
mkdir -p jdk/win32_15; cvs -d :pserver:anonymous@ottcvs1:/home/cvs/releng co $windows15JdkArchive;unzip -qq $windows15JdkArchive -d jdk/win32_15/; rm $windows15JdkArchive

#get and install the Windows Foundation jre containing the 1.0 Java libraries against which to compile
mkdir -p jdk/win32_foundation; cvs -d :pserver:anonymous@ottcvs1:/home/cvs/releng co $windows10FoundationArchive;unzip -qq $windows10FoundationArchive -d jdk/win32_foundation/; rm $windows10FoundationArchive

#get and install the Windows 1.6 Java libraries against which to compile
mkdir -p jdk/win32_16; cvs -d :pserver:anonymous@ottcvs1:/home/cvs/releng co $windows16JdkArchive;unzip -qq $windows16JdkArchive -d jdk/win32_16/; rm $windows16JdkArchive

if [ "$HOSTNAME" == "eclipsebuildserv.ottawa.ibm.com" ]
then
    #get then install the Linuxppc vm used for running the build
    mkdir -p jdk/linuxppc; cd jdk/linuxppc; cvs -d :pserver:anonymous@ottcvs1:/home/cvs/releng co $linuxppcJdkArchive; tar -xzf $linuxppcJdkArchive; rm $linuxppcJdkArchive
    #get then install the Linuxppc 1.5 vm used for generating javadoc
    cd jdk/linuxppc; cvs -d :pserver:anonymous@ottcvs1:/home/cvs/releng co $linuxppcJdkArchive15; tar -xzf $linuxppcJdkArchive15; rm -rf $linuxppcJdkArchive15; cd ../..
    javadoc="-Djavadoc15=$builderDir/jdk/linuxppc/ibm-java2-ppc-50/bin/javadoc"
fi

mkdir -p $postingDirectory/$buildLabel
chmod -R 755 $builderDir

#default value of the bootclasspath attribute used in ant javac calls.  
bootclasspath="$builderDir/jdk/win32/jdk1.4.2_16/jre/lib/rt.jar:$builderDir/jdk/win32/jdk1.4.2_16/jre/lib/jsse.jar"

bootclasspath_15="$builderDir/jdk/win32_15/jdk1.5.0_14/jre/lib/rt.jar"
bootclasspath_16="$builderDir/jdk/win32_16/jdk6_04/jre/lib/rt.jar"
bootclasspath_foundation="$builderDir/jdk/win32_foundation/lib/jclFoundation10/classes.zip"

if [ "$HOSTNAME" == "eclipsebuildserv.ottawa.ibm.com" ]
then
    PATH=$BASE_PATH:$builderDir/eclipseInternalBuildTools/bin/linux/:$builderDir/jdk/linuxppc/IBMJava2-ppc-142/jre/bin;export PATH
else
    PATH=$BASE_PATH:$builderDir/eclipseInternalBuildTools/bin/linux/:$builderDir/jdk/linux/jdk1.5.0_11/jre/bin;export PATH
fi

cd $builderDir/org.eclipse.releng.eclipsebuilder

echo buildId=$buildId >> monitor.properties 
echo timestamp=$timestamp >> monitor.properties 
echo buildLabel=$buildLabel >> monitor.properties 
echo recipients=$recipients >> monitor.properties
echo textRecipients=$textRecipients >> monitor.properties
echo log=$postingDirectory/$buildLabel/index.php >> monitor.properties

#the base command used to run AntRunner headless
antRunner="`which java` -Xmx500m -jar ../org.eclipse.releng.basebuilder/plugins/org.eclipse.equinox.launcher.jar -Dosgi.os=linux -Dosgi.ws=gtk -Dosgi.arch=ppc -application org.eclipse.ant.core.antRunner"
antRunnerJDK15="$builderDir/jdk/linuxppc/ibm-java2-ppc-50/jre/bin/java -Xmx500m -jar ../org.eclipse.releng.basebuilder/plugins/org.eclipse.equinox.launcher.jar -Dosgi.os=linux -Dosgi.ws=gtk -Dosgi.arch=ppc -application org.eclipse.ant.core.antRunner"

#clean drop directories
		 $antRunner -buildfile eclipse/helper.xml cleanSites

echo recipients=$recipients
echo postingDirectory=$postingDirectory
echo builderTag=$buildProjectTags
echo buildDirectory=$buildDirectory

#full command with args
buildCommand="$antRunner -q -buildfile buildAll.xml $mail $testBuild $compareMaps -DmapVersionTag=$mapVersionTag -DpostingDirectory=$postingDirectory -Dbootclasspath=$bootclasspath -DbuildType=$buildType -D$buildType=true -DbuildId=$buildId -Dbuildid=$buildId -DbuildLabel=$buildLabel -Dtimestamp=$timestamp -DmapCvsRoot=:ext:sdimitro@dev.eclipse.org:/cvsroot/eclipse $skipPerf $skipTest $skipPack $tagMaps -DJ2SE-1.5=$bootclasspath_15 -DJ2SE-1.4=$bootclasspath -DCDC-1.0/Foundation-1.0=$bootclasspath_foundation -DJavaSE-1.6=$bootclasspath_16 -DlogExtension=.xml $javadoc $updateSite $sign -DgenerateFeatureVersionSuffix=true -Djava15-home=$builderDir/jdk/linuxppc/ibm-java2-ppc-50/jre -listener org.eclipse.releng.build.listeners.EclipseBuildListener"

#capture command used to run the build
echo $buildCommand>command.txt

#run the build
$buildCommand
retCode=$?

if [ $retCode != 0 ]
then
        echo "Build failed (error code $retCode)."
		 exit $retCode
fi

if [ "$skip.feed" != "true" ]
then
buildCommandRSS="$antRunnerJDK15 -buildfile $builderDir/org.eclipse.releng.basebuilder/plugins/org.eclipse.build.tools/scripts_rss/feedManipulation.xml"
echo $buildCommandRSS>commandRSS.txt
#run the RSS command
$buildCommandRSS
fi

#clean up
rm -rf $builderDir


