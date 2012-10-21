#!/usr/bin/env bash

# this function accomplished "from a client" the same function that 
# could be done like this, on the download server (in .../eclipse/downloads directory): 
# php createIndex4x.php > index.html
# php eclipse3x.php > eclipse3x.html

function internalUpdateIndex () 
{

    if [[ $# != 2 ]] 
    then
        echo "PROGRAM ERROR: this function requires to arguments, in order, "
        echo "    the php page to use to create the html page, named in second argument)."
        exit 1
    fi 

    PHP_PAGE=$1
    HTML_PAGE=$2

    TEMP_INDEX_TXT=tempIndex.txt

    wget --no-verbose -O ${TEMP_INDEX_TXT} http://download.eclipse.org/eclipse/downloads/${PHP_PAGE} 2>&1
    rccode=$?
    if [ $rccode -eq 0 ]
    then
        rsync ${TEMP_INDEX_TXT} /home/data/httpd/download.eclipse.org/eclipse/downloads/${HTML_PAGE}
        rccode=$?
        if [ $rccode -eq 0 ] 
        then
            echo "INFO: Upated http://download.eclipse.org/eclipse/downloads/${HTML_PAGE}"
            return 0
        else
            echo "ERROR: Could not copy ${HTML_PAGE} to downlaods. rccode: $rccode"
            return $rccode
        fi
    else
        echo "ERROR: Could not create or pull ${TEMP_INDEX_TXT} from downloads file ${PHP_PAGE}. rccode: $rccode"
        return $rccode
    fi

    rm ${TEMP_INDEX_TXT}
}


function updateIndex () 
{


    x4X_PHP_PAGE="createIndex4x.php"
    x4X_HTML_PAGE="index.html"
    x3X_PHP_PAGE="eclipse3x.php"
    x3X_HTML_PAGE="eclipse3x.html"

    # if no arguments, do both, else we expect "3" or "4"
    # TODO: would be polite to detect unexpected arguments and give warnings. 
    if [[ $# == 0 ]] 
    then 
        internalUpdateIndex ${x4X_PHP_PAGE} ${x4X_HTML_PAGE}
        internalUpdateIndex ${x3X_PHP_PAGE} ${x3X_HTML_PAGE}
    else
        if [[ "$1" == "3" ]] 
        then 
            internalUpdateIndex ${x3X_PHP_PAGE} ${x3X_HTML_PAGE}
        elif [[ "$1" == "4" ]]
        then
            internalUpdateIndex ${x4X_PHP_PAGE} ${x4X_HTML_PAGE}
        fi
    fi

}


