   
   eclipseStream=4.2.0
   
      # contrary to intuition (and previous behavior, bash 3.1) do NOT use quotes around right side of expression. 
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
           