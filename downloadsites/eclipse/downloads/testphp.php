<?php



include('dlconfig4.php');

function startsWithDropPrefix($dirName, $dropPrefix)
{  

    $result = false;
    // sanity check "setup" is as we expect
    if (isset($dropPrefix) && is_array($dropPrefix)) {
        // sanity check input
        if (isset($dirName) && strlen($dirName) > 0) {
            $firstChar = substr($dirName, 0, 1);
            echo "first char: ".$firstChar;
            foreach($dropPrefix as $type) {  
                if ($firstChar == "$type") {
                    $result = true;
                    break;
                }
            }
        }
    }
    else {
        echo "dropPrefix not defined as expected\n";
    }
    return $result;
}
echo startsWithDropPrefix("Iname",$dropPrefix)."\n";
echo startsWithDropPrefix("ZMname",$dropPrefix)."\n";
echo startsWithDropPrefix("",$dropPrefix)."\n";
echo startsWithDropPrefix("4",$dropPrefix)."\n";
echo startsWithDropPrefix("Mname",$dropPrefix)."\n";

?>
