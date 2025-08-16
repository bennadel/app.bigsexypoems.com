
<!--- Import core custom tag libraries. --->
<cfimport prefix="core" taglib="../dsl/core/" />
<cfimport prefix="html" taglib="../dsl/core/html/" />

<!--- Define custom tag attributes. --->
<cfparam name="attributes.align" type="string" default="center" />
<cfparam name="attributes.href" type="string" />
<cfparam name="attributes.margins" type="string" default="none normal" />

<!--- // ------------------------------------------------------------------------- // --->
<!--- // ------------------------------------------------------------------------- // --->

<cfswitch expression="#thistag.executionMode#">
	<cfcase value="end">
		<cfoutput>

			<cfset theme = getBaseTagData( "cf_email" ).theme />

			<core:HtmlEntityTheme entity="a" class="dd-cta-outer-link">
				display: block ;
			</core:HtmlEntityTheme>
			<core:HtmlEntityTheme entity="a" class="dd-cta-inner-link">
				border: 0 ;
				color: #theme.light.onPrimary# ;
				display: block ;
				letter-spacing: 0.5px ;
			</core:HtmlEntityTheme>
			<core:HtmlEntityTheme entity="td" class="dd-cta-bgcolor">
				background-color: #theme.light.primary# ;
				border-radius: 48px 48px 48px 48px ;
				font-size: 16px ;
				line-height: 1 ;
				padding: 16px 36px 16px 36px ;
			</core:HtmlEntityTheme>

			<!---
				In order to "align" the table (left, center, right) without having
				content flow around it, we need to implement the alignment using "align"
				on the outer TD as opposed to "align" on the table. This way, the outer
				table acts as the BLOCK element and the inner table acts as the INLINE
				element.
			--->
			<html:table width="100%" margins="#attributes.margins#">
			<html:tr>
				<html:td align="#attributes.align#">

					<html:a href="#encodeForHtmlAttribute( attributes.href )#" decoration="false" class="dd-cta-outer-link">
						<!--- NOTE: Cellpadding needed for older email clients. --->
						<html:table cellpadding="16" margins="none">
						<html:tr>
							<html:td class="dd-cta-bgcolor">
								<html:a href="#encodeForHtmlAttribute( attributes.href )#" decoration="false" class="dd-cta-inner-link">

									<!---
										NOTE: We don't want to control this with font-
										weight since a bold font-weight is going to be
										tightly coupled to the font-family that is loaded
										(which won't be consistent across all clients).
									--->
									<html:strong>#thistag.generatedContent#</html:strong>

								</html:a>
							</html:td>
						</html:tr>
						</html:table>
					</html:a>

				</html:td>
			</html:tr>
			</html:table>

			<!--- Reset the generated content since we're overriding the output. --->
			<cfset thistag.generatedContent = "" />

		</cfoutput>
	</cfcase>
</cfswitch>
