
<!--- Import core custom tag libraries. --->
<cfimport prefix="core" taglib="../dsl/core/" />
<cfimport prefix="html" taglib="../dsl/core/html/" />

<!--- Import application custom tag libraries. --->
<cfimport prefix="app" taglib="./" />

<!--- // ------------------------------------------------------------------------- // --->
<!--- // ------------------------------------------------------------------------- // --->

<cfswitch expression="#thistag.executionMode#">
	<cfcase value="start">
		<cfoutput>

			<cfinclude template="./theme.cfm" />

		</cfoutput>
	</cfcase>
	<cfcase value="end">
		<cfoutput>

			<!--- The width-wrapper creates a responsive, centered layout. --->
			<app:BodyWidthWrapper>

				<!--- The content-wrapper creates the "chrome" around the email. --->
				<app:BodyContentWrapper>

					#thistag.generatedContent#

				</app:BodyContentWrapper>

			</app:BodyWidthWrapper>

			<!--- Reset the generated content since we're overriding the output. --->
			<cfset thistag.generatedContent = "" />

		</cfoutput>
	</cfcase>
</cfswitch>
