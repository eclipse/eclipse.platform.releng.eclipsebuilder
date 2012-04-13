# I always forget  ... hmm, neither? 
# MUST use (( )) to get it evaluated, 
# but then zero is false, non-zero is true
# still confusing


zero=0

if (( ${zero} ))
then
    echo "yes, zero is true"
else
    echo "no, zero is false"
fi

someother=99

if (( ${someother} ))
then
    echo "no, something non-zero is true"
else
    echo "yes, non-zero is false"
fi