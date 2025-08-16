
<!--- Import core custom tag libraries. --->
<cfimport prefix="core" taglib="../dsl/core/" />
<cfimport prefix="html" taglib="../dsl/core/html/" />

<!--- Import application custom tag libraries. --->
<cfimport prefix="app" taglib="./" />

<!--- // ------------------------------------------------------------------------- // --->
<!--- // ------------------------------------------------------------------------- // --->

<cfswitch expression="#thistag.executionMode#">
	<cfcase value="end">
		<cfoutput>

			<core:HtmlEntityTheme entity="td" class="dd-body-content">
				padding: 25px 0px 0px 0px ;
			</core:HtmlEntityTheme>
			<!--- Setup responsive styles. --->
			<core:MaxWidthStyles>
				.dd-body-content {
					padding: 15px 0px 0px 0px ;
				}
			</core:MaxWidthStyles>

			<app:BodyTopBorder />

			<!--- Cell-padding needed for older clients. --->
			<html:table width="100%" cellpadding="25">
			<html:tr>
				<html:td class="dd-body-content">

					<!--- This will be the main content of the email. --->
					#thistag.generatedContent#

				</html:td>
			</html:tr>
			</html:table>

			<app:BodyFooter />

			<!--- Reset the generated content since we're overriding the output. --->
			<cfset thistag.generatedContent = "" />

		</cfoutput>
	</cfcase>
</cfswitch>
