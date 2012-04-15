<?php
require_once($_SERVER['DOCUMENT_ROOT'] . "/eclipse.org-common/system/app.class.php");
require_once($_SERVER['DOCUMENT_ROOT'] . "/eclipse.org-common/system/nav.class.php");
require_once($_SERVER['DOCUMENT_ROOT'] . "/eclipse.org-common/system/menu.class.php");

$App 	= new App();
$Nav	= new Nav();
$Menu 	= new Menu();
include($App->getProjectCommon()); 
# All on the same line to unclutter the user's desktop'

	#*****************************************************************************
	#
	# sample_list.php
	#
	# Author: 		Denis Roy
	# Date:			2005-11-07
	#
	# Description: Type your page comments here - these are not sent to the browser
	#
	#
	#****************************************************************************
	
	#
	# Begin: page-specific settings.  Change these. 
	$pageTitle 		= "Sample three-column list web page using the new templates";
	$pageKeywords	= "Type, page, keywords, here";
	$pageAuthor		= "Type your name here";
	
	# Add page-specific Nav bars here
	# Format is Link text, link URL (can be http://www.someothersite.com/), target (_self, _blank), level (1, 2 or 3)
	# $Nav->addNavSeparator("My Page Links", 	"downloads.php");
	# $Nav->addCustomNav("My Link", "mypage.php", "_self", 3);
	# $Nav->addCustomNav("Google", "http://www.google.com/", "_blank", 3);

	# End: page-specific settings
	#
		
	# Paste your HTML content between the markers!	
ob_start();
?>		

	<div id="midcolumn">


<?php

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
</body></html>



		<h1><?= $pageTitle ?></h1>
		<h2>Sample list page</h2>
		<p>This is some intro text.<br /> <a href="#">more about eclipse &raquo;</a> </p>
		<h3>This is a title</h3>
		<hr size="1" />
		<p>Some text...</p>

		<h3>This is a title</h3>
		<hr size="1" />
		<p>Some text...</p>
	</div>

	<!-- remove the entire <div> tag to omit the right column!  -->
	<div id="rightcolumn">
		<div class="sideitem">
			<h6>Right column</h6>
			<ul>
				<li><a href="#">Item</a></li>
				<li><a href="#">Item</a></li>
				<li><a href="#">Item</a></li>
				<li><a href="#">Item</a></li>
			</ul>
		</div>
		<div class="sideitem">
			<h6>Another box</h6>
			<ul>
				<li><a href="#">Item</a></li>
				<li><a href="#">Item</a></li>
			</ul>
		</div>
	</div>

<?php
	$html = ob_get_contents();
	ob_end_clean();

	# Generate the web page
	$App->generatePage($theme, $Menu, $Nav, $pageAuthor, $pageKeywords, $pageTitle, $html);
?>
