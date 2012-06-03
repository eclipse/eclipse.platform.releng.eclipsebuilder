#!/usr/bin/env bash
#
# This utility is to double check the "sanity" of the map files
# produced in earlier step. 
# Repos must be checked out on the branch you
# expect to tag, map file tags already computed, "added" to repo, 
# and committed (to local workspace), but not yet pushed ... not good
# to push, if turns our there are errors and we cancel build. 
# 
#
# USAGE: repoRoot buildTag relengRoot repoURL [repoURL]*
#    repoRoot   - absolute path to a folder containing cloned git repositories
#    buildTag   - build tag to tag all repositories
#    relengRoot - asolute path to releng project containing map files
#    repoURL    - git repository urls to check, must match entries in the map files (i.e. git://... form)
# EXAMPLE: 
#   ./git-map-check.sh \
#   /opt/public/eclipse/eclipse3I/build/supportDir/gitCache \
#   I20120529-2100 \
#   /opt/public/eclipse/eclipse3I/build/supportDir/gitCache/eclipse.platform.releng.maps/org.eclipse.releng \
#   $( cat clones.txt ) | tee mapcheckout.txt 
# 
# returns 1 if FAILURE, else 0. Examine the maps-check.txt file for details.
#

LOGFILE="${PWD}/maps-check.txt"
echo "LOGFILE: $LOGFILE"
echo "# `basename ${0}` started at $( date +%Y%m%d-%H%M%S )" > "${LOGFILE}"
START_TIME=`date +%s`

check_map () {
	#echo check_map "$@"
	REPO=$1
	REPO_DIR=$( basename $REPO .git )
	MAP=$2
	 # assume no error, 0, but set to true, 1, if error found
	FOUND_ERROR=0
	pushd "$gitCache/$REPO_DIR" >/dev/null
	grep "repo=${REPO}," "$MAP" >/tmp/maplines_$$.txt
	# check that file exists and is not empty. 
    # (probably some type of an error if it does not, 
    # but, not the type of error we are interested in here). 
	if [ ! -s /tmp/maplines_$$.txt ]; then
		return $FOUND_ERROR
	fi
	while read LINE; do
		LINE_START=$( echo $LINE | sed 's/^\([^=]*\)=.*$/\1/g' )
		PROJ_PATH=$( echo $LINE | sed 's/^.*path=//g' )
		CURRENT_TAG=$( echo $LINE | sed 's/.*tag=\([^,]*\),.*$/\1/g' )
		LAST_COMMIT=$( git rev-list -1 HEAD -- "$PROJ_PATH" )
        if [ -z "$LAST_COMMIT" ]; then
            echo "#SKIPPING $LINE_START, no commits for $PROJ_PATH" >> "${LOGFILE}"
            continue
        fi
		
		if ! ( git tag --contains $LAST_COMMIT | grep $CURRENT_TAG >/dev/null ); then
			echo FAIL $PROJ_PATH ":" $LAST_COMMIT not contained in $CURRENT_TAG ":" "$REPO" >> "${LOGFILE}"
			FOUND_ERROR=1
		else
			echo "OK $LINE_START $CURRENT_TAG" >> "${LOGFILE}"
		fi
	done </tmp/maplines_$$.txt
	rm -f /tmp/maplines_$$.txt
	popd >/dev/null
	return $FOUND_ERROR
}


STATUS=OK
STATUS_MSG=""
LATEST_SUBMISSION=""


if [ $# -lt 4 ]; then
  echo "USAGE: $0 repoRoot buildTag relengRoot repoURL [repoURL]*"
  exit 1
fi


gitCache=$1; shift
buildTag=$1; shift
RELENG=$1; shift
REPOS="$@"

echo "DEBUG: gitCache: $gitCache"
echo "DEBUG: buildTag: $buildTag"
echo "DEBUG: RELENG: $RELENG"
echo "DEBUG: REPOS: $REPOS"

# If there is one failure, the whole thing is a failure, 
# but, important to keep going to check all in one run, in case 
# there is more than one inaccuracy.
OVERALL_FAIL=0

cd $gitCache
for REPO in $REPOS; do
	
	MAPS=$( find $RELENG -name "*.map" -exec grep -l "repo=${REPO}," {} \; )
	echo " "
	echo "DEBUG: REPO: $REPO"
	echo "DEBUG: MAPS: $MAPS"
	if [ ! -z "$MAPS" ]; then
		for MAP in $MAPS; do
		    echo "DEBUG: MAP : $MAP"
			FAILED=$( check_map $REPO $MAP )
			if [[ $FAILED == 1 ]] 
			then 
			    OVERALL_FAIL=1;
			fi
		done
	fi
done
echo "# check maps file ended at $( date +%Y%m%d-%H%M%S )" >> "${LOGFILE}"
END_TIME=`date +%s`
ELAPSED=$((END_TIME-START_TIME))
echo "# Elapsed seconds: $ELAPSED" >> "${LOGFILE}"
exit $OVERALL_FAIL
