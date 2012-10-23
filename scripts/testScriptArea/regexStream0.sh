
   eclipseStream=4.11112.100
   echo "EclipseStream: $eclipseStream"

      if [[ "${eclipseStream}" =~ ([[:digit:]]*)\.([[:digit:]]*)\.([[:digit:]]*) ]]
       then
          eclipseStreamMajor=${BASH_REMATCH[1]}
          eclipseStreamMinor=${BASH_REMATCH[2]}
          eclipseStreamService=${BASH_REMATCH[3]}
       else
            echo "eclipseStream, $eclipseStream, must contain major, minor, and service versions, such as 4.2.0"
            exit 1
       fi
       echo "eclipseStream: $eclipseStream"
       echo "eclipseStreamMajor: $eclipseStreamMajor"
       echo "eclipseStreamMinor: $eclipseStreamMinor"
       echo "eclipseStreamService: $eclipseStreamService"
