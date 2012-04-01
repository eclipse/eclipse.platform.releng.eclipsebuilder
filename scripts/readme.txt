
# to "get started" fresh, these files can be "checked out" fresh with wget. 
# The first one is the main one, and will get everything else needed. 
# The second is a simple utility that will be sure to capture all the console output, 
# which is useful when debugging, but likely not needed during production runs. 
# (assuming, that is, there are other "redirections" to capture all the relevent logging output.)

# Getting these fresh each build not anticipated to be part of normal operations. 
# though suppose it could be if it was discovered we'd forget to update manually 
# when needed.

# using wget, you will have to chmod +x *.sh to make executable

wget -O masterBuild.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/masterBuild.sh?h=R4_2_primary
wget -O mbCaptureOutput.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/mbCaptureOutput.sh?h=R4_2_primary

# there are rsync methods to get, to maintain permissions

