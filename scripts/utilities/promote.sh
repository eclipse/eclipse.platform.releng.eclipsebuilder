#!/usr/bin/env bash
#
# Script to promote the latest build in the specified committers area
#

function usage() 
{
    printf "\n\tUsage: %s [-v] [-d] [-s] [-c] [-z] [-a] [-p] projectname " $(basename $0) >&2
    printf "\n\t\t%s\t%s" "-p <projectname>," "where projectname is a cc project, such as wtp-R3.2.3-M, wtp-R3.3.0-I, etc. from which to get latest build." >&2	
    printf "\n\t\t%s\t%s" "-v" "verbose" >&2
    printf "\n\t\t%s\t%s" "-d" "delete old builds" >&2
    printf "\n\t\t%s\t%s" "-s" "send notification mail" >&2
    printf "\n\t\t%s\t%s" "-c" "copy the build from committers to downloads" >&2
    printf "\n\t\t%s\t%s" "-z" "process artifacts (create pack200 gz jars, etc.) Remember, is long running" >&2 
    printf "\n\t\t%s\t%s" "-a" "add properties" >&2    
    printf "\n\t\t%s\t%s\n" "-h" "this help message" >&2
}

# This "print arsgs" funtion is mostly a debugging aide, to help spot mistakes in invocation or command processing.
# It could be later be changed to only print when in verbose mode, if seems like too much.
function printargs() 
{

echo "dump of script arguments"
if [ $verboseFlag ] 
 then
    echo "   verbose output requested"
  else
    echo "   verbose output NOT requested"
fi

if [ $deleteOld ] 
 then
    echo "   delete old requested"
  else
    echo "   delete old NOT requested"
fi

if [ $doCopy ] 
 then
    echo "   copy requested"
  else
    echo "   copy NOT requested"
fi

if [ $sendmail ] 
 then
    echo "   sendmail requested"
  else
    echo "   sendmail NOT requested"
fi

if [ $processArtifacts ] 
 then
    echo "   processArtifacts requested"
  else
    echo "   processArtifacts NOT requested"
fi

if [ $addProperties ] 
 then
    echo "   addProperties requested"
  else
    echo "   addProperties NOT requested"
fi

}

# see https://bugs.eclipse.org/bugs/show_bug.cgi?id=348028
# for why mx might have to be so large as 1G
# and this must be set early, since other's might read in commonVariations.shsource
#export IBM_JAVA_OPTIONS=${IBM_JAVA_OPTIONS:-"-Dcom.ibm.tools.attach.enable=no -Xmx1G -Declipse.p2.mirrors=false"}
export IBM_JAVA_OPTIONS=${IBM_JAVA_OPTIONS:-"-Dcom.ibm.tools.attach.enable=no  -Declipse.p2.mirrors=false"}


source rsync-retry.sh

verboseFlag=
deleteOld=
doCopy=
projectname=
processArtifacts=
addProperties=
while getopts 'hvdcszap:' OPTION
do
    case $OPTION in
        h)    usage
        exit 1
        ;;
        v)    verboseFlag=1
        ;;
        d)    deleteOld=1
        ;;
        c)    doCopy=1
        ;;
        s)    sendmail=1
        ;;
        z)    processArtifacts=1
        ;;
        a)    addProperties=1        
        ;;        
        # we strip off ".ser", if present, just to make it easier to use with tab completion, etc., from 
        # releng.control directory, were the project files are named, for example, "wtp-R3.3.0-I.ser"
         p)    projectname=${OPTARG%\.ser}
        ;;
        ?)    usage
        exit 2
        ;;
    esac
done

shift $(($OPTIND - 1))


printargs


# check we have at least the project name
if [ -z $projectname ]
then
    printf "\n\t%s\n"   "Error: project name is required." >&2
    usage
    exit 1
fi 

if [[ "$projectname" =~ (.*)-(.*)-(.*) ]] 
then
    distribution=${BASH_REMATCH[1]}
    buildBranch=${BASH_REMATCH[2]}
    buildType=${BASH_REMATCH[3]}
    printf "\n\t%s\n\n" "Promoting latest build from ${1} ..."
    if [ $verboseFlag ]
    then
        echo "distribution: $distribution"
        echo "buildBranch: $buildBranch"
        echo "buildType: $buildType"
    fi 
else
    printf "\n\t%s\n"   "Error: projectname doesn't match <distribution>-<buildbranch>-<buildtype> pattern." >&2
    usage
    exit 3
fi

# remember to leave no slashes on filename in source command,
# (the commonVariations.shsource file, that is)
# so that users path is used to find it (first)
if [ -z $BUILD_INITIALIZED ]
then
    source commonVariations.shsource
    source ${BUILD_HOME}/releng.control/commonComputedVariables.shsource
fi

artifactsDir=${PROJECT_ARTIFACTS}
promoteProjectDir=${artifactsDir}'/'${projectname}
if [ $verboseFlag ] 
then 
    echo "Project directory to promote: ${promoteProjectDir} "
fi 

if [ ! \( -d ${promoteProjectDir} \) ] 
then
    printf "\n\t%s\n"   "ERROR: directory ${promoteProjectDir} does not exist." >&2
    usage
    exit 4
fi

i=0
for FN in ${promoteProjectDir}/* 
do
    dirName=$(basename ${FN})
    if [ $verboseFlag ] 
    then 
        echo -n "${i}: "
        echo ${dirName}
    fi
    # todo: could check that the name follows the expected date pattern
    dirList[${i}]=${dirName}
    i=$(($i + 1))
done

nDir=${#dirList[*]}

if [ $verboseFlag ] 
then 
    echo "Number of directories: ${nDir}" 
fi 

# echo "Least recent: ${dirList[0]}"
# echo "Most  recent: ${dirList[$(($nDir - 1))]}"

mostRecent=${dirList[$(($nDir - 1))]}

mostRecentDir=${promoteProjectDir}/${mostRecent}


i=0
for FN in ${mostRecentDir}/* 
do
    dropDirName=$(basename ${FN})
    if [ $verboseFlag ] 
    then 
        echo -n "${i}: "
        echo ${dropDirName}
    fi
    # todo: could check that the name follows the expected drop directory pattern
    dropDirList[${i}]=${dropDirName}
    i=$(($i + 1))
done

ndropDir=${#dropDirList[*]}

# there should be exactly one drop directory
if [ $ndropDir != 1 ] 
then 
    printf "\n\t%s\n"   "Error: there was not exactly one drop direc:tory. There was $ndropDir found instead." >&2
    usage
    exit 5
fi

# knowing there is exactly one, the value of dropDirName is still valid

echo "Drop directory: ${dropDirName}"

FROMDIR=${mostRecentDir}/${dropDirName}

# make sure RC has a value, in case no paths are taken that set it
RC=0

if [[ $processArtifacts ]] 
then
#run pack200 (and, recompute checksums) before literally promoting


       repoDirLocation=$FROMDIR/repository
       if [[ -d "${repoDirLocation}" ]] 
       then
              echo "INFO: processing artifacts in code repo: $repoDirLocation";
              ${RELENG_CONTROL}/runAntRunner.sh process-artifacts.xml -DrepoDirLocation="${repoDirLocation}" 
              RC=$?
       else 
              echo "ERROR: expected code repo directory does not exist: $repoDirLocation";
              RC=2001
       fi 
       
       if [ $RC -eq 0 ] 
       then 
              repoDirLocation=$FROMDIR/repositoryunittests
              if [[ -d "${repoDirLocation}" ]] 
              then
                     echo "INFO: calling processing artifacts in test repo: $repoDirLocation";
                     ${RELENG_CONTROL}/runAntRunner.sh process-artifacts.xml -DrepoDirLocation="${repoDirLocation}"
                     RC=$?
              else 
                     echo "ERROR: expected test repo directory does not exist: $repoDirLocation";
                     RC=2002
              fi 
       fi
fi 

if [ $RC != 0 ]
  then
     echo "ERROR: pack processing did not operate as expected. Exiting the promote script early."
     exit $RC
   fi

# Remember, add properties should be called after process artifacts. 
# TODO: we currently do not add properties to tests repo ... maybe should? for mirror URL, at least. 
# TODO: a fourth and fifth argument can be specified to addRepoProperties.sh to provide better stats marking. 
# A version indicator that becomes part of URI, such as /helios, /indigo, etc, and
# a suffix, to signify releases, such as  
# such as _helios_SR2, _indigo_SR0 ... but, these will take some customization, and remember to update them fairly often, to be accurate.
# And, we do not particularly use anyway. 
# Also, the addProperties app has some ability to add name property (but not in our releng repo yet). 
if [[ $addProperties ]] 
then 
   repoDirLocation=$FROMDIR/repository
   if [[ -d "${repoDirLocation}" ]]
       then
              ${RELENG_CONTROL}/addRepoProperties.sh "${repoDirLocation}" "${buildBranch}" "${dropDirName}"
       else 
              echo "ERROR: addProperties requested, but repo location does not exist: ${repoDirLocation}";
       fi
fi 

if [ "patches" == $distribution ] 
then
   TODIR=${DOWNLOAD_ROOT}/webtools/patches/drops/${buildBranch}/
else
   TODIR=${DOWNLOAD_ROOT}/webtools/downloads/drops/${buildBranch}/
fi

printf "\t%s\n"         "declaring build ${dropDirName} on buildstream  ${buildBranch}"
printf  "\t\t%s\n"      "into ${TODIR}"
printf  "\t\t%s\n\n"   "using the build from ${FROMDIR}"

if [ $doCopy ] 
then
	rsync-retry ${FROMDIR} ${TODIR} $verboseFlag
	exitCode=$?
	if [ $exitCode -ne 0 ] 
	then 
		exit $exitCode
	fi

    fromString="webtools/committers"
    if [ "patches" == $distribution ] 
    then
      toString="webtools/patches"
    else
      toString="webtools/downloads"
    fi
    replaceCommand="s!${fromString}!${toString}!g"

    # remember TODIR already has a slash
    perl -w -pi -e ${replaceCommand} ${TODIR}${dropDirName}/*.php

    # now do the composite reference site update
    
    case $buildType in
        R )
            referenceCompositeDir=${BUILD_HOME}/integration;;
        S )
            referenceCompositeDir=${BUILD_HOME}/integration;;
        I )
            referenceCompositeDir=${BUILD_HOME}/integration;;
        M )
            referenceCompositeDir=${BUILD_HOME}/maintenance;;
        * )
            printf "warning: 'buildType' ($buildType) was not an expected value."
            printf "        composite reference not updated." ;;
    esac
    if [ ! -z referenceCompositeDir ] 
    then
        dropDirectory=${TODIR}${dropDirName}
        ./runAntRunner.sh "${PWD}/updateReferenceComposite.xml" "-DreferenceCompositeDir=$referenceCompositeDir" "-DdropDirectory=$dropDirectory"
    fi 
else
    printf  "\n\t%s\n\n"   "Nothing copied: specify -c to actually do the copy"
fi 

if [ $sendmail ]
then
    ./sendPromoteMail.sh "$projectname" "$TODIR" "$dropDirName"
    echo "mail sent"
else
    echo "no mail sent. Specify -s if desired"
fi 


if [ $deleteOld ] 
then 

    maxToDelete=$(($nDir - 1))
    if [ $verboseFlag ]
    then
        echo "maxToDelete: $maxToDelete"
    fi
    for (( i=0; i < $maxToDelete; i++)) 
    do
        dirbasename=${dirList[$i]}
        dropDirName=${promoteProjectDir}/${dirbasename}
        if [ $verboseFlag ]
        then
            echo -n "${i}: "
            echo ${dropDirName}
        fi
        rm -fr ${dropDirName}
    done

fi

printargs
