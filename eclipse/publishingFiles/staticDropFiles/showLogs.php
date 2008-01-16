<?php
        $hasNotes = false;
        $aDirectory = dir($myDir);
        $index = 0;
        while ($anEntry = $aDirectory->read()) {
                if ($anEntry != "." && $anEntry != "..") {
                        $entries[$index] = $anEntry;
                        $index++;
                }
        }

        aDirectory.closedir();
        sort($entries);

        echo "<table>";
        for ($i = 0; $i < $index; $i++) {
                $anEntry = $entries[$i];
                $line = "<td>Component: <a href=\"$myDir/$anEntry\">$anEntry</a></td>";
                echo "<tr>";
                echo "$line";
                echo "</tr>";
                $hasNotes = true;
        }
        echo "</table>";

        if (!$hasNotes) {
                echo "<br>There are no test logs for this build.";
        }
?>