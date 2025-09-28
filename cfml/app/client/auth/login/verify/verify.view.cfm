<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<p>
			If this page doesn't automatically redirect you to the application in a few seconds, please click the submit button below.
		</p>

		<form
			method="post"
			action="#request.postBackAction#"
			x-prevent-double-submit>
			<cfmodule template="/client/_shared/tag/xsrf.cfm">

			<button
				type="submit"
				x-auto-submit-button
				class="uiButton isSubmit">
				Continue to App &rarr;
			</button>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
