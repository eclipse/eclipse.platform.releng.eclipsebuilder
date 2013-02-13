#!/usr/bin/env bash

# Note for production. Simple test cases to verify script to get basebuilder, 
# from CVS or Git, saving each version (with mv) to diff afterwards

# defaults to CGit (fetchSource=git) , builderVersion=R38M6PlusRC3G 
ant -f getBaseBuilder.xml 
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-G-git 

# get previously used version
ant -f getBaseBuilder.xml -DbuilderVersion=R38M6PlusRC3F
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-F-git 

# get previously used version
ant -f getBaseBuilder.xml -DbuilderVersion=R38M6PlusRC3D
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-D-git 

# get previously used version
ant -f getBaseBuilder.xml -DbuilderVersion=R38M6PlusRC3C
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-C-git 

# do same with CVS

ant -f getBaseBuilder.xml -DfetchSource=cvs
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-D-cvs 

ant -f getBaseBuilder.xml -DbuilderVersion=R38M6PlusRC3C -DfetchSource=cvs 
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-C-cvs 

# try some older ones
ant -f getBaseBuilder.xml -DbuilderVersion=R36_RC4
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-R36_RC4-git 

ant -f getBaseBuilder.xml -DbuilderVersion=R36_RC4 -DfetchSource=cvs 
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-R36_RC4-cvs 

ant -f getBaseBuilder.xml -DbuilderVersion=R37_M7
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-R37_M7-git 

ant -f getBaseBuilder.xml -DbuilderVersion=R37_M7 -DfetchSource=cvs 
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-R37_M7-cvs 

ant -f getBaseBuilder.xml -DbuilderVersion=R35_RC4
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-R35_RC4-git 

ant -f getBaseBuilder.xml -DbuilderVersion=R35_RC4 -DfetchSource=cvs 
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-R35_RC4-cvs 

# versions used for previous final releases or patch builds
#3.4.x   buildProjectTags=r34x_v20120319
#3.5.x   buildProjectTags=r35x_v20120319
#3.6.x   buildProjectTags=r36x_v20120306
#3.6.2j7 buildProjectTags=r36x_v20120306
#3.7.2   buildProjectTags=R3_7_maintenance

buildProjectTags=r34x_v20120319
ant -f getBaseBuilder.xml -DbuilderVersion=$buildProjectTags
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-$buildProjectTags-git 

ant -f getBaseBuilder.xml -DbuilderVersion=$buildProjectTags -DfetchSource=cvs 
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-$buildProjectTags-cvs 

buildProjectTags=r35x_v20120319
ant -f getBaseBuilder.xml -DbuilderVersion=$buildProjectTags
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-$buildProjectTags-git 

ant -f getBaseBuilder.xml -DbuilderVersion=$buildProjectTags -DfetchSource=cvs 
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-$buildProjectTags-cvs 

buildProjectTags=r36x_v20120306
ant -f getBaseBuilder.xml -DbuilderVersion=$buildProjectTags
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-$buildProjectTags-git 

ant -f getBaseBuilder.xml -DbuilderVersion=$buildProjectTags -DfetchSource=cvs 
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-$buildProjectTags-cvs 

buildProjectTags=r36x_v20120306
ant -f getBaseBuilder.xml -DbuilderVersion=$buildProjectTags
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-$buildProjectTags-git 

ant -f getBaseBuilder.xml -DbuilderVersion=$buildProjectTags -DfetchSource=cvs 
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-$buildProjectTags-cvs 

buildProjectTags=R3_7_maintenance
ant -f getBaseBuilder.xml -DbuilderVersion=$buildProjectTags
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-$buildProjectTags-git 

ant -f getBaseBuilder.xml -DbuilderVersion=$buildProjectTags -DfetchSource=cvs 
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-$buildProjectTags-cvs 
