#!/usr/bin/env bash

#Sample utility to wget files related to promotion


# we say "branch or tag", but for tag, the wget has to use tag= instead of h=
branchOrTag=master

# remember that wget puts most its output on "standard error", I assume 
# following the philosophy that anything "diagnosic" related goes to standard err, 
# and only things the user really needs wants to see as "results" goes to standard out

wget -O syncDropLocation.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/syncDropLocation.sh?h=$branchOrTag 2>/dev/null
wget -O sdkPromotionCronJob.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/sdkPromotionCronJob.sh?h=$branchOrTag 2/dev/null

