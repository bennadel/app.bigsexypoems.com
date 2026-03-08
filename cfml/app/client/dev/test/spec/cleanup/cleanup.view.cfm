<cfsavecontent variable="request.response.body">
<cfoutput>

	<h1>
		#e( title )#
	</h1>

	<p>
		This will delete all test users (and their cascaded data) created by the test runner and then optimize the affected database tables.
	</p>

	<cfmodule
		template="/client/_shared/tag/errorMessage.cfm"
		response="#errorResponse#">
	</cfmodule>

	<form
		method="post"
		action="#request.postBackAction#"
		x-prevent-double-submit>
		<cfmodule template="/client/_shared/tag/xsrf.cfm" />

		<div class="uiFormButtons">
			<button type="submit" class="uiButton isSubmit">
				Clean Up Test Data
			</button>
		</div>
	</form>

</cfoutput>
</cfsavecontent>
