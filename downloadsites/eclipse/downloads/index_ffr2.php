<html><head>
<link rel="stylesheet" href="../default_style.css">
<title>Eclipse Project Downloads</title></head>
<body>
<?php

        $serverName = $HTTP_SERVER_VARS["SERVER_NAME"];
	
	if (strstr($serverName, ".oti.com")) {
		$warning = '<br><font color="#FF0000" size="+2">Internal OTI Mirror. Live external site is <a href="http://download.eclipse.org/downloads" target="_top">here</a>. </font>';
                $serverName = $HTTP_SERVER_VARS["SERVER_NAME"];
	} else {
		$warning = '';
	}
	$testBoxes=array("linux.gtk.x86", "linux.gtk.x86_6.0", "macosx.carbon.ppc_5.0", "win32.win32.x86", "win32.win32.x86_6.0");
	$length=count($testBoxes);
	for ($i = 0 ; $i < $length ; i++) {
		echo "$testBoxes[$i], ";
	}
	echo "<br>";
?> <table border=0 cellspacing=5 cellpadding=2 width="100%" > <tr> <td align=left width="72%"> 
<font class=indextop> eclipse project<br>downloads</font> <br> <font class=indexsub> 
latest downloads from the eclipse project</font><br> <?php echo $warning; ?> </td><td width="28%"><img src="../images/Idea.jpg" height=86 width=120></td><!--  <td width="19%" rowspan="2"><a href="http://www.eclipsecon.org/" target="_blank"><img src="../images/prom-eclipsecon1.gif" width="125" height="125" border="0"></a></td> --> 
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
<B>Other eclipse.org project</B> downloads are available <A HREF="http://www.eclipse.org/downloads/index.php">here</A>.</p>

<p>
<img src="../images/new.gif">
Help out with Eclipse translations - check out the <a href="http://babel.eclipse.org/babel/"><strong>Babel project</strong></a>.   </p>
 
<p>Looking 
for the build schedule then look <a href="http://www.eclipse.org/eclipse/platform-releng/buildSchedule.html" target="_top">here</a>. 
For information about different kinds of builds look <a href="build_types.html" target="_top">here</a>. 
For access to archived builds, including language packs, look <a href="http://archive.eclipse.org/eclipse/downloads/index.php" target="_top">here</p><p></p></td></tr> 
</table><?php

       $contents = substr(file_get_contents('dlconfig.txt'),0,-1);
       $contents = str_replace("\n", "", $contents);

        #split the content file by & and fill the arrays
        $elements = explode("&",$contents);
        $t = 0; 
        $p = 0;
        for ($c = 0; $c < count($elements)-1; $c++) {
		$tString = "dropType";
                $pString = "dropPrefix";
    	        if (strstr($elements[$c],$tString)) {
                   $temp = preg_split("/=/",$elements[$c]);
                   $dropType[$t] = $temp[1];
                   $t++;
                }
    	        if (strstr($elements[$c],$pString)) {
                   $temp = preg_split("/=/",$elements[$c]);
                   $dropPrefix[$p] = $temp[1];
                   $p++;
                }
        }
	
	for ($i = 0; $i < count($dropType); $i++) {
		$typeToPrefix[$dropType[$i]] = $dropPrefix[$i];
	}
	
	$aDirectory = dir("drops");
	while ($anEntry = $aDirectory->read()) {

		// Short cut because we know aDirectory only contains other directories.

		if ($anEntry != "." && $anEntry!=".." && $anEntry!="TIME") {
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
			
				if ($timeStamp > $latestTimeStamp[$parts[0]]) {
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

                                if ($timeStamp > $latestTimeStamp[$buildType]) {
                                        $latestTimeStamp[$buildType] = $timeStamp;
                                        $latestFile[$buildType] = $anEntry;
                                }
                        }
		}
	}
 ?>
<?php
function runTestBoxes($buildName) {
	$buildDir = dir("drops/$buildName");
	$count=0;
	while ($file = $buildDir->read()) {
		$length=count($testBoxes);
		for ($i = 0 ; $i < $length ; $i++) {
			if (strcmp($file, $testBoxes[$i]) == 0) {
				$count++;
				break;
			}
		}
	}
	return $count;
}
?>
<?php
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
	//$build_done=file_exists("$dropDir/checksum/swt-$buildName-win32-wce_ppc-arm-j2me.zip.md5");
	echo "<td valign=baseline>";
	$runTestBoxes=runTestBoxes($buildName);
	if ($runTestBoxes > 0) {
		echo "<a href=\"$dropDir/index.php\"><img border=\"0\" src=\"../images/build_done.gif\" title=\"Build is available\"/></a>&nbsp;";
		//$testResults="$dropDir/testresults/xml";
		//if (file_exists("$testResults")) {
		if ($runTestBoxes == 5) {
			echo "<a href=\"$dropDir/testResults.php\"><img border=\"0\" src=\"../images/junit.gif\" title=\"Tests results are available\"/></a>&nbsp;";
		} else {
			// if more than 12 hours then consider that the regression tests did not finish
			if ($diff > 720) {
				echo "<img src=\"../images/caution.gif\" title=\"Regression tests did not run or did not finish!\">";
			} else {
				echo "<img src=\"../images/runtests.gif\" title=\"Regression tests are running...\">&nbsp;";
			}
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
						echo "<img src=\"../images/caution.gif\" title=\"Performance tests ran but no results are available: either they were not stored in DB or not generated!\">";
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
