#!/usr/bin/env bash

# Note for production. Simple test cases to verify script to get basebuilder, 
# from CVS or Git, saving each version (with mv) to diff afterwards

# defaults to CGit (fetchSource=git) , builderVersion=R38M6PlusRC3D 
ant -f getBaseBuilder.xml 
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-D-git 

# get previously used version
ant -f getBaseBuilder.xml -DbuilderVersion=R38M6PlusRC3C
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-C-git 

# do same with CVS

ant -f getBaseBuilder.xml -DfetchSource=cvs
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-D-cvs 

ant -f getBaseBuilder.xml -DbuilderVersion=R38M6PlusRC3C -DfetchSource=cvs 
mv org.eclipse.releng.basebuilder org.eclipse.releng.basebuilder-C-cvs 

