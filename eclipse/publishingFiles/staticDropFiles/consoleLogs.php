<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<?php
		 $parts = explode("/", getcwd());
		 $parts2 = explode("-", $parts[count($parts) - 1]);
		 $buildName = $parts2[0] . "-" . $parts2[1];
		 
		 // Get build type names

		 $fileHandle = fopen("../../dlconfig2.txt", "r");
		 while (!feof($fileHandle)) {
		 		 
		 		 $aLine = fgets($fileHandle, 4096); // Length parameter only optional after 4.2.0
		 		 $parts = explode(",", $aLine);
		 		 $dropNames[trim($parts[0])] = trim($parts[1]);
 		 }
		 fclose($fileHandle);

		 $buildType = $dropNames[$parts2[0]];

		 echo "<title>Logs for $buildType $buildName </title>";
?>
<STYLE TYPE="text/css">
<!--
P {text-indent: 30pt;}
-->
</STYLE>


<title>Logs</title>
		 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		 <meta name="author" content="Eclipse Foundation, Inc." />
		 <meta name="keywords" content="eclipse,project,plug-ins,plugins,java,ide,swt,refactoring,free java ide,tools,platform,open source,development environment,development,ide" />
		 <link rel="stylesheet" type="text/css" href="../../../eclipse.org-common/stylesheets/visual.css" media="screen" />
		 <link rel="stylesheet" type="text/css" href="../../../eclipse.org-common/stylesheets/layout.css" media="screen" />
		 <link rel="stylesheet" type="text/css" href="../../../eclipse.org-common/stylesheets/print.css" media="print" />
		 <script type="text/javascript">

sfHover = function() {
		 var sfEls = document.getElementById("leftnav").getElementsByTagName("LI");
		 for (var i=0; i<sfEls.length; i++) {
		 		 sfEls[i].onmouseover=function() {
		 		 		 this.className+=" sfhover";
		 		 }
		 		 sfEls[i].onmouseout=function() {
		 		 		 this.className=this.className.replace(new RegExp(" sfhover\\b"), "");
		 		 }
		 }
}
if (window.attachEvent) window.attachEvent("onload", sfHover);
</script>
</head>
<body>
<div id="header">
		 <a href="/"><img src="../../../eclipse.org-common/stylesheets/header_logo.gif" width="163" height="68" border="0" alt="Eclipse Logo" class="logo" /></a>
		 <div id="searchbar">
		 		 <img src="../../../eclipse.org-common/stylesheets/searchbar_transition.gif" width="92" height="26" class="transition" alt="" />
		 		 <img src="../../../eclipse.org-common/stylesheets/searchbar_header.gif" width="64" height="17" class="header" alt="Search" />
		 		 <form method="get" action="/search/search.cgi">
		 		 		 <input type="hidden" name="t" value="All" />
		 		 		 <input type="hidden" name="t" value="Doc" />
		 		 		 <input type="hidden" name="t" value="Downloads" />
		 		 		 <input type="hidden" name="t" value="Wiki" />
		 		 		 <input type="hidden" name="wf" value="574a74" />
		 		 		 <input type="text" name="q" value="" />
		 		 		 <input type="image" class="button" src="../../../eclipse.org-common/stylesheets/searchbar_submit.gif" alt="Submit" onclick="this.submit();" />
		 		 </form>
		 </div>
		 <ul id="headernav">
		 		 <li class="first"><a href="/org/foundation/contact.php">Contact</a></li>
		 		 <li><a href="/legal/">Legal</a></li>
		 </ul>
</div><div id="topnav">
		 <ul>
		 		 <li><a>Platform Navigation</a></li>
		 		 <li class="tabstart">&#160;&#160;&#160;</li>
		 		 <li><a class="" href="index.php" target="_self">All Platforms</a></li>
		 		 <li class="tabstart">&#160;&#160;&#160;</li>
		 		 <li><a class="" href="winPlatform.php" target="_self">Windows</a></li>
		 		 <li class="tabstart">&#160;&#160;&#160;</li>
		 		 <li><a class="" href="linPlatform.php" target="_self">Linux</a></li>
		 		 <li class="tabstart">&#160;&#160;&#160;</li>
		 		 <li><a class="" href="solPlatform.php" target="_self">Solaris</a></li>
		 		 <li class="tabstart">&#160;&#160;&#160;</li>
		 		 <li><a class="" href="aixPlatform.php" target="_self">AIX</a></li>
		 		 <li class="tabstart">&#160;&#160;&#160;</li>		 		 
		 		 <li><a class="" href="macPlatform.php" target="_self">Macintosh</a></li>
		 		 <li class="tabseparator">&#160;&#160;&#160;</li>
		 		 <li><a class="" href="hpuxPlatform.php" target="_self">HP-UX</a></li>
		 		 <li class="tabseparator">&#160;&#160;&#160;</li>		 		 		 
		 </ul>
</div>
<div id="topnavsep"></div>
<div id="leftcol">
<ul id="leftnav">
<li><a href="testResults.php#Logs">Logs</a></li>
<li><a href="testResults.php#UnitTest">Unit Test Results</a></li>
<li><a href="testResults.php#PluginsErrors">Plugins Containing Compile Errors</a></li>
 
  </li>
  <li style="background-image: url(../../../eclipse.org-common/stylesheets/leftnav_fade.jpg); background-repeat: repeat-x; border-style: none;">
		 		 		 <br /><br /><br /><br /><br />
  </li>
</ul>

</div>


<div id="midcolumn">
<div class="homeitem">
<h3>Logs <?php echo "$buildType $buildName"; ?> </h3>
<ul>
<li> <a href="chkpiiResults.php"><b> CHKPII Tests Logs </b></a>
These logs only need to be checked if the org.eclipse.releng.tests above report a test failures. <?php if (! (preg_match("/N/i",$buildName))) { echo "<br><br>Cvs tag v$buildName of org.eclipse.releng.eclipsebuilder and org.eclipse.releng.basebuilder was used to create this build."; } ?>
</li>
<li> <strong>Console Output Logs</strong>

<?php
        global $myDir,$aDirectory;
        $myDir  = "testresults/consolelogs";
        include 'showLogs.php';
?>


</li>
<li>
<a href="buildLogs.php"><b> Javadoc Logs </b></a>
</li>
<?php if (! (preg_match("/N/i",$buildName))) {
echo " <li><a href=\"testresults/versiontool/results.xml\"><b> Versioning Compare Tool Output Logs </b></a>";
echo "This log compares the build's plugin and features versions with 3.3.1.1 </li> ";
}
?>
</div>
</div>

<div id="footer">
		 <ul id="footernav">
		 		 <li class="first"><a href="/">Home</a></li>
		 		 <li><a href="/legal/privacy.php">Privacy Policy</a></li>
		 		 <li><a href="/legal/termsofuse.php">Terms of Use</a></li>
		 </ul>
		 <p>Copyright &copy; 2006 The Eclipse Foundation. All Rights
Reserved</p>
</div>
</body>
</html>
