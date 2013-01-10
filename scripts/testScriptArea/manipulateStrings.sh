#!/usr/bin/env bash

    eclipseStream=${eclipseStream:-4.2}
    eclipseStreamMajor=${eclipseStream:0:1}
    echo "eclipseStream: $eclipseStream"
    echo "eclipseStreamMajor: $eclipseStreamMajor"

    
    es=4.2.2
esplain=${es//./}
echo "es: $es"
echo "esplain: $esplain"