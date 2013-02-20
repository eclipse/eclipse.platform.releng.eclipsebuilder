
# as desired, just one quote where needed in testfile.txt
eqFromDir="a"
eqToDir=b

echo "rsync -p -t --recursive \"${eqFromDir}\" \"${eqToDir}\"" > testfile.txt