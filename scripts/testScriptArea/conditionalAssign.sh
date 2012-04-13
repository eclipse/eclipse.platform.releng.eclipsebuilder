#!/usr/bin/env bash

# I've seen the :- form used when a "temporary" default value is desired,
# while could be overridden to one or the other if set
#
# if ${debug:-true}
# then
#     echo "by default do debug stuff here"
# fi
#
# if ${debug:-false}
# then
#     echo "by default do NOT do debug stuff here"
# fi
#

# I think for "initialiizing values if they haven't been set yet
# both would work the same, in these forms, since is assigning 
# DEBUG=${DEBUG:-true}
# DEBUG=${DEBUG:=true}
#
# apparently, if the line begins with a colon, you can get the 
# assignment done with this shorthand (but, I think not very readable)
# : ${DEBUG:=true}
#
# (but, not following, since "temporary", I'm assuming 
# : ${DEBUG:-true}
#

echo "===="
echo

echo "Test case 1 variable does not exist, when :- used"

if ${testvar:-true}
then
   echo "default testvar is true"
else
    echo "default testvar is false"
fi

echo "And testvar value later is $testvar"
echo
echo "===="
echo
echo "Test case 2 variable does exist, when :- used: "

    
testvar2=false            

if ${testvar2:-true}
 then
   echo "default testvar2 is true"
 else
    echo "default testvar2 is false"
fi

echo "And testvar2 value later is $testvar2"
 
echo
echo "===="
echo

echo "Test case 3 variable does not exist, when := used"

if ${testvar3:=true}
then
   echo "default testvar3 is true"
else
    echo "default testvar3 is false"
fi
echo "And testvar3 value later is $testvar3"

              
              
echo
echo "===="
echo

echo "Test case 4 variable does not exist, when := used"

if ${testvar4:=true}
then
   echo "default testvar is true"
else
    echo "default testvar is false"
fi
echo "And testvar4 value later is $testvar4"

                            