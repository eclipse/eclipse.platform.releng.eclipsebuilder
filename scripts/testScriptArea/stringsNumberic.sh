
# base seemes to convert strings to numeric, as would be expected
# or ... numbers to strings? 
# as long as "near right", works as expected, but 
# the last test case non-numeric can give odd results (comparing 'n' to '4'?) 
# I did use tests against 4.1, 4.3, etc., also (not just 4) 

# test cases 
#eclipseStream=4.2
eclipseStream="4.2"
#eclipseStream=3
#eclipseStream="3"
#eclipseStream="non number"


if [[ $eclipseStream > 4.31 ]] 
then
    echo "yes, $eclipseStream is greater than 4.31"
else
    echo "no, $eclipseStream is not greater than 4.31"
fi