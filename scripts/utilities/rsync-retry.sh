#!/usr/bin/env bash

function rsync-retry () {
    if [ -z $1 -o -z $2 ] 
    then
        echo "Invalid arguments. Usage is rsync-retry FROMDIR TODIR [verbose] [maxtrys] [pausetime]"
        return 1
    fi
    local FROMDIR=$1
    local TODIR=$2
    if [ -z $3 ]
    then
       local verboseFlag=0
    else
       local verboseFlag=$3
    fi
    
    if [ -z $4 ]
    then
       local maxTrys=5
    else
       local maxTrys=$4
    fi

    if [ -z $5 ]
    then
       local nPauseTime=120s
    else
       local nPauseTime=$5
    fi

    # do not use -t option. See bug 278471
    # https://bugs.eclipse.org/bugs/show_bug.cgi?id=278471

    local rsyncArgs="rup"
    if [ $verboseFlag -gt 0 ] 
    then
        rsyncArgs="${rsyncArgs}v"
    else
        rsyncArgs="${rsyncArgs}q"
    fi
     
    exitCode=-1
    nTrys=0
    
    until [ $exitCode == 0 ]
    do  
     rsync -${rsyncArgs} ${FROMDIR} ${TODIR}
     exitCode=$?
     if [ $exitCode != 0 ]
     then
         nTrys=$(($nTrys + 1))
         if [ $verboseFlag ] ; then
             echo "rsync failed with $exitCode. Retrying $nTrys times after $nPauseTime."
             if [ $nTrys -gt $maxTrys ] ; then
                 echo "Number of re-trys exceeded. rsync exit code: $exitCode"
                 return $exitCode
             fi
         sleep $nPauseTime
         fi
     fi 
    done
    
    return $exitCode
}
