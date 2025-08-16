
<!--- Import core custom tag libraries. --->
<cfimport prefix="core" taglib="../dsl/core/" />
<cfimport prefix="html" taglib="../dsl/core/html/" />

<!--- // ------------------------------------------------------------------------- // --->
<!--- // ------------------------------------------------------------------------- // --->

<cfswitch expression="#thistag.executionMode#">
	<cfcase value="end">
		<cfoutput>

			<core:HtmlEntityTheme entity="table">
				height: 2px ;
			</core:HtmlEntityTheme>
			<core:HtmlEntityTheme entity="td">
				background-color: ##4682b4 ;
				font-size: 1px ;
				height: 2px ;
				line-height: 1px ;
			</core:HtmlEntityTheme>

			<html:table width="100%" margins="none">
			<html:tr>
				<html:td>
					<br />
				</html:td>
			</html:tr>
			</html:table>

			<!--- Reset the generated content since we're overriding the output. --->
			<cfset thistag.generatedContent = "" />

		</cfoutput>
	</cfcase>
</cfswitch>
