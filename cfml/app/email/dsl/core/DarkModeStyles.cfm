
<!--- Define custom tag attributes. --->
<cfparam name="attributes.injectImportant" type="boolean" default="true" />
<cfparam name="attributes.runOnce" type="boolean" default="true" />

<!--- // ------------------------------------------------------------------------- // --->
<!--- // ------------------------------------------------------------------------- // --->

<cfswitch expression="#thistag.executionMode#">
	<cfcase value="end">
		<cfoutput>

			<cfset theme = getBaseTagData( "cf_email" ).theme />
			<cfset theme.enableDarkModeSupport = true />

			<cfmodule
				template="./MediaQueryStyles.cfm"
				queryName="prefers-color-scheme"
				queryValue="dark"
				injectImportant="#attributes.injectImportant#"
				runOnce="#attributes.runOnce#">
				#thistag.generatedContent#
			</cfmodule>

			<!--- Reset the generated content since we're overriding the output. --->
			<cfset thistag.generatedContent = "" />

		</cfoutput>
	</cfcase>
</cfswitch>
