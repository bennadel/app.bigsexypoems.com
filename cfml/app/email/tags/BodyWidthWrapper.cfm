
<!--- Import core custom tag libraries. --->
<cfimport prefix="core" taglib="../dsl/core/" />
<cfimport prefix="html" taglib="../dsl/core/html/" />

<!--- // ------------------------------------------------------------------------- // --->
<!--- // ------------------------------------------------------------------------- // --->

<cfswitch expression="#thistag.executionMode#">
	<cfcase value="end">
		<cfoutput>

			<cfset theme = getBaseTagData( "cf_email" ).theme />

			<!--- Setup responsive styles. --->
			<core:MaxWidthStyles>
				.dd-body-width-wrapper {
					width: 100% ;
				}
			</core:MaxWidthStyles>

			<!---
				This wrapper sets up the responsive width of the email content. It starts
				out fixed-width; but, on narrower devices, will fallback to using 100%
				width. As such everything INSIDE this wrapper can use 100% all the time
				(at least where it makes sense).
			--->
			<html:table width="#theme.width#" align="center" class="dd-body-width-wrapper">
			<html:tr>
				<html:td>

					#thistag.generatedContent#

				</html:td>
			</html:tr>
			</html:table>

			<!--- Reset the generated content since we're overriding the output. --->
			<cfset thistag.generatedContent = "" />

		</cfoutput>
	</cfcase>
</cfswitch>
