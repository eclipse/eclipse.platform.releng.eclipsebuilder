<?php  																														require_once("../eclipse.org-common/system/app.class.php");	require_once($_SERVER['DOCUMENT_ROOT'] . "/eclipse.org-common/system/nav.class.php"); 	require_once($_SERVER['DOCUMENT_ROOT'] . "/eclipse.org-common/system/menu.class.php"); 	$App 	= new App();	$Nav	= new Nav();	$Menu 	= new Menu();		include($App->getProjectCommon());    # All on the same line to unclutter the user's desktop'

	#*****************************************************************************
	#
	# sample_3col.php
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
	$pageTitle 		= "Sample three-column Phoenix web page using the new templates";
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
		<h1><?= $pageTitle ?></h1>
		<h2>Sample 3-column page</h2>
		<p>This is some intro text.<br /> <a href="#">more about eclipse &raquo;</a> </p>
		<div class="homeitem3col">
			<h3>This is a large column</h3>
			<ul>
				<li><a href="#">Eclipse Magazin, Volume 3 - Titelthema: Eclipse Rich Clients</a>. Zudem stellt das Eclipse Magazin seine <a href="#">'Eclipse Plug-in Collection'</a> vor, die ab sofort online verf&uuml;gbar ist. <span class="dates">02/05/05</span></li>
				<li><a href="#">Eclipse Magazin, Volume 3 - Titelthema: Eclipse Rich Clients</a>. Zudem stellt das Eclipse Magazin seine <a href="#">'Eclipse Plug-in Collection'</a> vor, die ab sofort online verf&uuml;gbar ist. <span class="dates">02/05/05</span></li>
			</ul>
		</div>
		<div class="homeitem3col">
			<h3>This is another large column</h3>
			<ul>
				<li><a href="#">Eclipse Magazin, Volume 3 - Titelthema: Eclipse Rich Clients</a>. Zudem stellt das Eclipse Magazin seine <a href="#">'Eclipse Plug-in Collection'</a> vor, die ab sofort online verf&uuml;gbar ist. <span class="dates">02/05/05</span></li>
			</ul>
		</div>
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
