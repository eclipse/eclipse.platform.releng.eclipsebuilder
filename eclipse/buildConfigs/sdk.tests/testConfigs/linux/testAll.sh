#!/usr/bin/env bash


# This file should never exist or be needed for production machine, 
# but allows an easy way for a "local user" to provide this file 
# somewhere on the search path ($HOME/bin is common), 
# and it will be included here, thus can provide "override values" 
# to those defined by defaults for production machine., 
# such as for vmcmd

source localTestsProperties.shsource

echo "PWD: $PWD"
vmcmd=${vmcmd:-/shared/common/jdk-1.6.x86_64/jre/bin/java}

echo "vmcmd: $vmcmd"

# production machine is x86_64, but some local setups may be 32 bit and will need to provide 
# this value in localTestsProperties.shsource.
eclipseArch=${eclipseArch:-x86_64}

# vm.properties is used by default on production machines, but will 
# need to override on local setups to specify appropriate vm (usually same as vmcmd). 
# see bug 388269
propertyFile=${propertyFile:-vm.properties}

echo "extdir in testAll: ${extdir}"

#execute command to run tests
/bin/chmod 755 runtests.sh
/bin/mkdir -p results/consolelogs

if [[ -n "${extdir}" ]]
then
./runtests.sh -os linux -ws gtk -arch $eclipseArch -extdirprop "${extdir}" -vm "${vmcmd}" -properties ${propertyFile} $* > results/consolelogs/linux.gtk.x86_6.0_consolelog.txt
else 
./runtests.sh -os linux -ws gtk -arch $eclipseArch -vm "${vmcmd}" -properties ${propertyFile} $* > results/consolelogs/linux.gtk.x86_6.0_consolelog.txt	
fi


