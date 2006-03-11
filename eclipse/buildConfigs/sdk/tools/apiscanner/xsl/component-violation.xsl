<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:use="http://eclipse.org/wtp/releng/tools/component-use">
	<xsl:template match="/">
		<html>
			<body>
				<h2><xsl:value-of select="use:component-use/@name"/></h2>
				<xsl:for-each select="use:component-use/source">
					<h3><xsl:value-of select="@name"/></h3>
					<ul>
						<xsl:for-each select="class-use">
							<xsl:if test="@reference">
								<li><p>
									<b>Reference:&#160;</b><xsl:value-of select="@name"/>
									<ul>
										<xsl:for-each select="method-api">
											<li><b>Method:&#160;</b><xsl:value-of select="@name"/>&#160;<i><xsl:value-of select="@descriptor"/></i></li>
										</xsl:for-each>
									</ul>
									<ul>
										<xsl:for-each select="field-api">
											<li><b>Field:&#160;</b><xsl:value-of select="@name"/>&#160;<i><xsl:value-of select="@descriptor"/></i></li>
										</xsl:for-each>
									</ul>
								</p></li>
							</xsl:if>
						</xsl:for-each>
					</ul>
					<ul>
						<xsl:for-each select="class-use">
							<xsl:if test="@subclass">
								<li><p>
									<b>Subclass:&#160;</b><xsl:value-of select="@name"/>
								</p></li>
							</xsl:if>
						</xsl:for-each>
					</ul>
					<ul>
						<xsl:for-each select="class-use">
							<xsl:if test="@implement">
								<li><p>
									<b>Implement:&#160;</b><xsl:value-of select="@name"/>
								</p></li>
							</xsl:if>
						</xsl:for-each>
					</ul>
					<ul>
						<xsl:for-each select="class-use">
							<xsl:if test="@instantiate">
								<li><p>
									<b>Instantiate:&#160;</b><xsl:value-of select="@name"/>
								</p></li>
							</xsl:if>
						</xsl:for-each>
					</ul>
				</xsl:for-each>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
