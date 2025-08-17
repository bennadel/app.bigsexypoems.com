<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiFlow">

		<h1>
			#e( title )#
		</h1>

		<p>
			If this page doesn't automatically redirect you to the application in a few seconds, please click the submit button below.
		</p>

		<form
			x-data="lzlbk2.FormController"
			method="post"
			action="#request.postBackAction#"
			@submit="handleSubmit( event )">
			<cfmodule template="/client/_shared/tag/xsrf.cfm">

			<button
				type="submit"
				x-ref="button"
				:disabled="isSubmitting"
				class="uiButton isSubmit">
				Continue to App &rarr;
			</button>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
