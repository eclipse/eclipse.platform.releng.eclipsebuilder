#!/usr/bin/env bash

#Sample utility to wget files related to promotion


# we say "branch or tag", but for tag, the wget has to use tag= instead of h=
branchOrTag=master

# remember that wget puts most its output on "standard error", I assume 
# following the philosophy that anything "diagnosic" related goes to standard err, 
# and only things the user really needs wants to see as "results" goes to standard out
# but in cron jobs and similar, this comes across as "an error".

wget --no-verbose -O syncDropLocation.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/promotionRelated/syncDropLocation.sh?h=$branchOrTag 2>&1
wget --no-verbose -O sdkPromotionCronJob.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/promotionRelated/sdkPromotionCronJob.sh?h=$branchOrTag 2>&1
wget --no-verbose -O wgetSDKPromoteScripts.NEW.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/promotionRelated/wgetSDKPromoteScripts.sh?h=$branchOrTag 2>&1

chmod +x *.sh