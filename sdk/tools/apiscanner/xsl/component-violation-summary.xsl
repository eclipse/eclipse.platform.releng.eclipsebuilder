<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:use="http://eclipse.org/wtp/releng/tools/component-use">
	<xsl:template match="/">
		<html>
			<body>
				<h2>Component Violation Summary</h2>
				<table border="1">
					<tr>
						<th><h3><b>Component name</b></h3></th>
						<th><h3><b>Violation count</b></h3></th>
					</tr>
					<xsl:for-each select="component-violation-summary/component-violation">
						<tr>
							<td><a href="{@ref}"><xsl:value-of select="@name"/></a>&#160;</td>
							<td><xsl:value-of select="@count"/></td>
						</tr>
					</xsl:for-each>
				</table>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
