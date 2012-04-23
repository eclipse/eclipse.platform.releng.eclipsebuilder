These scripts may need variables, if not data, such as 

I removed from the primary build script, since not used there ... but leaving
small note here, in case it helps reconstruct the tests. 

    #rembember, don't point to e4Build user directory
    sdkTestDir=${buildRoot}/sdkTests/$buildTag
    sdkResults=$buildDir/$buildTag/$buildTag
    sdkBuildDirectory=$buildDir/$buildTag
    
    
    
I had to change hudson jobs in that they were getting both basebuidler and
eclipsebuilder from cvs, still. 

So, I changed so hudson job go only eclipse builder, but then hudson 
involved .../testScripts/....sh and the first thing that script did, 
was get basebuilder from cvs, THEN invoke the script that used 
to be on hudson ... similar to: 

NOTE: move scripts back to "root" of eclipseBuilder, since 
a lot of code seemed to depend on that (with relative directories, etc.)

/shared/common/jdk-1.6.x86_64/bin/java -Xmx500m -jar $WORKSPACE/WORKSPACE/org.eclipse.releng.basebuilder/plugins/org.eclipse.equinox.launcher.jar -DWORKSPACE=$WORKSPACE  -DbuildId=$buildId -DBUILD_WORKSPACE=$BUILD_WORKSPACE -DBUILD_JOB_NAME=$BUILD_JOB_NAME -DBUILD_BUILD_NUMBER=$BUILD_BUILD_NUMBER -DBUILD_ID=$BUILD_ID -Dosgi.os=linux -Dosgi.ws=gtk -Dosgi.arch=x86_64 -Dhudson=true -Dcurrentbuildrepo=$currentbuildrepo -Djava.home=$JAVA_HOME -application org.eclipse.ant.core.antRunner -v -f $WORKSPACE/WORKSPACE/org.eclipse.releng.eclipsebuilder/runTests2.xml
    