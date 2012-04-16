
# to "get started" fresh, these files can be "checked out" fresh with wget. 
# The first one is the main one, and will get everything else needed. 
# The second is a simple utility that will be sure to capture all the console output, 
# which is useful when debugging, but likely not needed during production runs. 
# (assuming, that is, there are other "redirections" to capture all the relevent logging output.)

# Getting these fresh each build not anticipated to be part of normal operations. 
# though suppose it could be if it was discovered we'd forget to update manually 
# when needed.

# using wget, you will have to chmod +x *.sh to make executable (at least, first 
# time)

wget -O masterBuild.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/masterBuild.sh?h=master;
wget -O mb3I.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/mb3I.sh?h=master;
wget -O mb4I.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/mb4I.sh?h=master;
wget -O mb4N.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/mb4N.sh?h=master;

# to get "promote" scripts

wget -O syncRepoSite.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/syncRepoSite.sh?h=master;
wget -O sendPromoteMail.shsource http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/sendPromoteMail.shsource?h=master;
wget -O syncDropLocation.shsource http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/syncDropLocation.shsource?h=master;
wget -O syncDropLocation.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/syncDropLocation.sh?h=master;


# there are rsync methods to get, to maintain permissions

# occasionally may need to get the git-release.sh script to do a "manual" automatic tag
# normally should be checked out/start from "supportDir" for now, I believe.
wget -O git-release.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/git-release.sh?h=master;
