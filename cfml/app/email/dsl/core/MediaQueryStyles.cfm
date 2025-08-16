
<!--- Define custom tag attributes. --->
<cfparam name="attributes.injectImportant" type="boolean" default="true" />
<cfparam name="attributes.media" type="string" default="screen" />
<cfparam name="attributes.queryName" type="string" />
<cfparam name="attributes.runOnce" type="boolean" default="true" />
<cfparam name="attributes.queryValue" type="string" />

<!--- // ------------------------------------------------------------------------- // --->
<!--- // ------------------------------------------------------------------------- // --->

<cfswitch expression="#thistag.executionMode#">
	<cfcase value="end">
		<cfoutput>

			<cfmodule
				template="./HeaderStyles.cfm"
				injectImportant="#attributes.injectImportant#"
				runOnce="#attributes.runOnce#">
				@media #attributes.media# and ( #attributes.queryName#: #attributes.queryValue# ) {

					#thistag.generatedContent#

				}
			</cfmodule>

			<!--- Reset the generated content since we're overriding the output. --->
			<cfset thistag.generatedContent = "" />

		</cfoutput>
	</cfcase>
</cfswitch>
