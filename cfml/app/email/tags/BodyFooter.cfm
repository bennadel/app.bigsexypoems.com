
<!--- Import core custom tag libraries. --->
<cfimport prefix="core" taglib="../dsl/core/" />
<cfimport prefix="html" taglib="../dsl/core/html/" />

<!--- // ------------------------------------------------------------------------- // --->
<!--- // ------------------------------------------------------------------------- // --->

<cfswitch expression="#thistag.executionMode#">
	<cfcase value="end">
		<cfoutput>

			<cfset providers = getBaseTagData( "cf_email" ).providers />
			<cfset siteName = providers[ "site.name" ] />
			<cfset sitePublicUrl = providers[ "site.publicUrl" ] />

			<core:HtmlEntityTheme entity="td" class="dd-body-footer">
				background-color: ##f8f8fa ;
				border-top: 1px solid ##ebecee ;
				font-size: 12px ;
				letter-spacing: 0.25px ;
				line-height: 17px ;
				padding: 20px 10px 20px 10px ;
			</core:HtmlEntityTheme>
			<core:HtmlEntityTheme entity="a" class="dd-body-footer-link">
				color: ##276ee5 ;
			</core:HtmlEntityTheme>
			<!--- Setup dark-mode styles - only works in a few clients. --->
			<core:DarkModeStyles>
				.dd-body-footer {
					background-color: ##262626 ;
					border-top-color: ##666666 ;
					color: ##cccccc ;
				}

				.dd-body-footer-link {
					color: ##88b5ff ;
				}
			</core:DarkModeStyles>

			<!--- NOTE: Cell-padding needed for older mail clients. --->
			<html:table width="100%" cellpadding="20">
			<html:tr>
				<html:td align="center" class="dd-body-footer">

					<html:a href="#encodeForHtmlAttribute( sitePublicUrl )#" decoration="false" class="dd-body-footer-link"><html:strong>#encodeForHtml( siteName )#</html:strong></html:a>

				</html:td>
			</html:tr>
			</html:table>

			<!--- Reset the generated content since we're overriding the output. --->
			<cfset thistag.generatedContent = "" />

		</cfoutput>
	</cfcase>
</cfswitch>
