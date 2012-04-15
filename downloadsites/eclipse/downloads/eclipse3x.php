<html><head>
<link rel="stylesheet" href="../default_style.css">
<title>Eclipse Project Downloads</title></head>
<body>
<table border=0 cellspacing=5 cellpadding=2 width="100%" > <tr> <td align=left width="72%"> 
<font class=indextop> eclipse project<br>downloads</font> <br> <font class=indexsub> 
latest downloads from the eclipse project</font><br> </td><td width="28%"><img src="../images/friendslogo.jpg"><br>Support Eclipse! Become a <a href="http://www.eclipse.org/donate/">friend</a>.</br></td><!--  <td width="19%" rowspan="2"><a href="http://www.eclipsecon.org/" target="_blank"><img src="../images/prom-eclipsecon1.gif" width="125" height="125" border="0"></a></td> --> 
</tr> </table><table border=0 cellspacing=5 cellpadding=2 width="100%" > <tr> 
<td align=LEFT valign=TOP colspan="2" bgcolor="#0080C0"><b><font color="#FFFFFF" face="Arial,Helvetica">Latest 
Downloads</font></b></td></tr> <!-- The Eclipse Projects --> <tr> <td> <p>On this 
page you can find the latest <a href="build_types.html" target="_top">builds</a> produced by 
the <a href="http://www.eclipse.org/eclipse" target="_top">Eclipse 
Project</a>. To get started run the program and go through the user and developer 
documentation provided in the online help system. If you have problems downloading 
the drops, contact the <font size="-1" face="arial,helvetica,geneva"><a href="mailto:webmaster@eclipse.org">webmaster</a></font>. 
If you have problems installing or getting the workbench to run, <a href="http://wiki.eclipse.org/index.php/The_Official_Eclipse_FAQs" target="_top">check 
out the Eclipse Project FAQ,</a> or try posting a question to the <a href="http://www.eclipse.org/newsgroups" target="_top">newsgroup</a>. 
All downloads are provided under the terms and conditions of the <a href="http://www.eclipse.org/legal/epl/notice.php" target="_top">Eclipse Foundation 
Software User Agreement</a> unless otherwise specified. </p>

See <a href="http://www.eclipse.org/downloads/index.php">other eclipse.org
project downloads</a>.
</p>

<p>
<img src="../images/new.gif"> <a href="http://download.eclipse.org/eclipse/downloads/"><strong>Eclipse 4.x downloads available here!</strong></a>   
<br>Help out with Eclipse translations - check out the <a href="http://babel.eclipse.org/babel/"><strong>Babel project</strong></a>. 
<br><a href="http://build.eclipse.org/technology/phoenix/torrents/SDK/"><strong>SDK Torrents</strong></a> </p> 
 
<p>
See also the <a href="http://www.eclipse.org/eclipse/platform-releng/buildSchedule.html">build schedule</a>, read information about different <a href="build_types.html">kinds of
builds</a>, access <a href="http://archive.eclipse.org/eclipse/downloads/index.php">archived builds</a> (including language packs), or see a list of 
<a href="http://wiki.eclipse.org/Eclipse_Project_Update_Sites">p2 update sites</a>.

</table>

<?php

include('dlconfig3.php');
for ($i = 0; $i < count($dropType); $i++) {
    $typeToPrefix[$dropType[$i]] = $dropPrefix[$i];
}

function startsWithDropPrefix($dirName, $dropPrefix)
{  

    $result = false;
    // sanity check "setup" is as we expect
    if (isset($dropPrefix) && is_array($dropPrefix)) {
        // sanity check input
        if (isset($dirName) && strlen($dirName) > 0) {
            $firstChar = substr($dirName, 0, 1);
            //echo "first char: ".$firstChar;
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
	
	$aDirectory = dir("drops");
	while ($anEntry = $aDirectory->read()) {

		// Short cut because we know aDirectory only contains other directories.

		if ($anEntry != "." && $anEntry!=".." && $anEntry!="TIME" && startsWithDropPrefix($anEntry,$dropPrefix)) {
			$parts = explode("-", $anEntry);
			if (count($parts) == 3) {

				$buckets[$parts[0]][] = $anEntry;
	
				$timePart = $parts[2];
				$year = substr($timePart, 0, 4);
				$month = substr($timePart, 4, 2);
				$day = substr($timePart, 6, 2);
				$hour = substr($timePart,8,2);
				$minute = substr($timePart,10,2);
				$timeStamp = mktime($hour, $minute, 0, $month, $day, $year);
				
				$timeStamps[$anEntry] = date("D, j M Y -- H:i (O)", $timeStamp);
            // latestTimeStamp will not be defined, first time through
            if (!isset($latestTimeStamp) || !array_key_exists($parts[0],$latestTimeStamp)  || $timeStamp > $latestTimeStamp[$parts[0]]) {
					$latestTimeStamp[$parts[0]] = $timeStamp;
					$latestFile[$parts[0]] = $anEntry;
				}
			}

			if (count($parts) == 2) {

                                $buildType=substr($parts[0],0,1);
                                $buckets[$buildType][] = $anEntry;
                                $datePart = substr($parts[0],1);
                                $timePart = $parts[1];
                                $year = substr($datePart, 0, 4);
                                $month = substr($datePart, 4, 2);
                                $day = substr($datePart, 6, 2);
                                $hour = substr($timePart,0,2);
                                $minute = substr($timePart,2,2);
                                $timeStamp = mktime($hour, $minute, 0, $month, $day, $year);
                                $timeStamps[$anEntry] = date("D, j M Y -- H:i (O)", $timeStamp);

            if (!array_key_exists($buildType,$latestTimeStamp) || $timeStamp > $latestTimeStamp[$buildType]) {
                                        $latestTimeStamp[$buildType] = $timeStamp;
                                        $latestFile[$buildType] = $anEntry;
                                }
                        }
		}
	}

function runTestBoxes($buildName) {
	$testBoxes=array("linux", "macosx", "win32");
	$length=count($testBoxes);
	$boxes=0;
	if (file_exists("drops/$buildName/testresults")) {
		$buildDir = dir("drops/$buildName/testresults");
		while ($file = $buildDir->read()) {
			for ($i = 0 ; $i < $length ; $i++) {
				if (strncmp($file, $testBoxes[$i], count($testBoxes[$i])) == 0) {
					$boxes++;
					break;
				}
			}
		}
	}
	return $boxes;
}

function printBuildColumns($fileName, $parts) {
	// no file name, write empty column
	if ($fileName == "") {
		echo "<td></td>";
		return;
	}
	// get build name, date and time
	$dropDir="drops/$fileName";
	if (count($parts)==3) {
		$buildName=$parts[1];
		$buildDay=intval(substr($parts[2], 0, 8));
		$buildTime=intval(substr($parts[2], 8, 4));
	}
	if (count($parts)==2) {
		$buildName=$fileName;
		$buildDay=intval(substr($buildName, 1, 8));
		$buildTime=intval(substr($buildName, 10, 2))*60+intval(substr($buildName, 12, 2));
	}
	// compute minutes elapsed since build started
	$day=intval(date("Ymd"));
	$time=intval(date("H"))*60+intval(date("i"));
	$diff=($day-$buildDay)*24*60+$time-$buildTime;
	// Add icons
	$build_done=file_exists("$dropDir/checksum/swt-$buildName-win32-wce_ppc-arm-j2me.zip.md5");
	echo "<td valign=baseline>";
	if ($build_done) {
		$boxes=runTestBoxes($fileName);
		echo "<a href=\"$dropDir/index.php\"><img border=\"0\" src=\"../images/build_done.gif\" title=\"Build is available\"/></a>&nbsp;";
		//$testResults="$dropDir/testresults/xml";
		//if (file_exists("$testResults")) {
        	$serverName = $HTTP_SERVER_VARS["SERVER_NAME"];
//		$ottawaServer=strstr($serverName, ".ottawa.ibm.com");
//echo "$diff:";
		switch ($boxes) {
		case 0:
			// if more than 8 hours then consider that the regression tests did not start
			if ($diff > 480) {
				echo "<img src=\"../images/caution.gif\" title=\"Regression tests did not run!\">";
			} else {
				echo "<img src=\"../images/runtests.gif\" title=\"Regression tests are running...\">&nbsp;";
			}
			break;

		case 5:
			echo "<a href=\"$dropDir/testResults.php\"><img border=\"0\" src=\"../images/junit.gif\" title=\"Tests results are available\"/></a>&nbsp;";
			break;
		default:
			// if more than 12 hours then consider that the regression tests did not finish
			if ($diff > 720) {
				echo "<a href=\"$dropDir/testResults.php\"><img border=\"0\" src=\"../images/junit.gif\" title=\"Tests results are available but did not finish on all machines\"/></a>&nbsp;";
			} else {
        			//$serverName = $HTTP_SERVER_VARS["SERVER_NAME"];
				//if (strstr($serverName, ".ottawa.ibm.com")) {
//				if ($ottawaServer) {
//					echo "<a href=\"$dropDir/testresults\"><img border=\"0\" src=\"../images/runtests.gif\" title=\"Tests results are available on some machines\"/></a>&nbsp;";
//				} else {
					echo "<img border=\"0\" src=\"../images/runtests.gif\" title=\"Tests are still running on some machines...\"/>&nbsp;";
//				}
			}
			break;
		}
		$perfsDir="$dropDir/performance";
		if (file_exists("$perfsDir")) {
			$perfsFile="$perfsDir/performance.php";
			if (file_exists("$perfsFile")) {
				if (file_exists("$perfsDir/global.php")) {
					echo "<a href=\"$perfsFile\"><img border=\"0\" src=\"../images/perfs.gif\" title=\"Performance tests are available\"/></a>";
				} else {
					echo "<img src=\"../images/caution.gif\" title=\"Performance tests ran and results should have been generated but unfortunately they are not available!\">";
				}
			} else {
				if (file_exists("$perfsDir/consolelogs")) {
					// if more than one day then consider that perf tests did not finish
					if ($diff > 1440) {
						if (substr($buildName, 0, 1) == "I") {
							$reason="see bug 259350";
						} else {
							$reason="either they were not stored in DB or not generated";
						}
						echo "<img src=\"../images/caution.gif\" title=\"Performance tests ran but no results are available: $reason!\">";
					} else {
						echo "<img src=\"../images/runperfs.gif\" title=\"Performance tests are running...\">";
					}
				}
			}
		}
	} else {
		// if more than 5 hours then consider that the build did not finish
		if ($diff > 300) {
			echo "<img src=\"../images/build_failed.gif\" title=\"Build failed!\">";
		} else {
			echo "<img src=\"../images/build_progress.gif\" title=\"Build is in progress...\">";
		}
	}
	echo "</td>";
      return $buildName;
}
?>
<table width="100%" cellspacing=0 cellpadding=3 align=center> <td align=left> 
<TABLE  width="100%" CELLSPACING=0 CELLPADDING=3>
<tr>
<td width="30%"><b>Build Type</b></td>
<td width="15%"><b>Build Name</b></td>
<td width="15%"><b>Build Status</b></td>
<td><b>Build Date</b></td>
</tr>
<?php
	foreach($dropType as $value) {
		$prefix=$typeToPrefix[$value];
		$fileName = $latestFile[$prefix];
		
		$parts = explode("-", $fileName);

		// Uncomment the line below if we need click through licenses.
		// echo "<td><a href=license.php?license=drops/$fileName>$parts[1]</a></td>";

		// Comment the line below if we need click through licenses.
		echo "<tr>";
		echo "<td>$value</td>";
		$buildName=$fileName;
		if (count($parts)==3) {
			$buildName=$parts[1];
		}
		if ($fileName == "") {
			echo "<td></td>";
		} else {
			echo "<td><a href=\"drops/$fileName/index.php\">$buildName</a></td>";
		}
		$buildName = printBuildColumns($fileName, $parts);
		echo "<td>$timeStamps[$fileName]</td>";
		echo "</tr>";
	}
?>
</table></table>&nbsp;
<?php
	foreach($dropType as $value) {
		$prefix=$typeToPrefix[$value];
		echo "
		<table width=\"100%\" cellspacing=0 cellpadding=3 align=center>
		<tr bgcolor=\"#999999\">
		<td align=left width=\"30%\"><b><a name=\"$value\"><font color=\"#FFFFFF\" face=\"Arial,Helvetica\">$value";
		echo "s</font></b></a></td>
		</TR>
		<TR>
		<td align=left>
		<TABLE  width=\"100%\" CELLSPACING=0 CELLPADDING=3>
		<tr>
		<td width=\"15%\"><b>Build Name</b></td>
		<td width=\"15%\"><b>Build Status</b></td>
		<td><b>Build Date</b></td>
		</tr>";
		
		$aBucket = $buckets[$prefix];
		if (isset($aBucket)) {
			rsort($aBucket);
			foreach($aBucket as $innerValue) {
				if (strcmp($innerValue, "I20081216-0801") == 0)
					continue;
				$parts = explode("-", $innerValue);
				echo "<tr>";
				
				// Uncomment the line below if we need click through licenses.
				// echo "<td><a href=\"license.php?license=drops/$innerValue\">$parts[1]</a></td>";
			
				// Comment the line below if we need click through licenses.
				$buildName=$innerValue;
				if (count($parts)==3) {
					$buildName=$parts[1];
				}
				echo "<td><a href=\"drops/$innerValue/index.php\">$buildName</a></td>";
				$buildName = printBuildColumns($innerValue, $parts);
				echo "<td>$timeStamps[$innerValue]</td>";
				echo "</tr>";
			}
		}
		echo "</table></table>&nbsp;";
	}
?> &nbsp; 
</body></html>
