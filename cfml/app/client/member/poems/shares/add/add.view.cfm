<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiFlow uiReadableWidth">

		<h1>
			#e( title )#
		</h1>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			response="#errorResponse#">
		</cfmodule>

		<form method="post" action="#request.postBackAction#">
			<cfmodule template="/client/_shared/tag/xsrf.cfm">

			<div class="uiField">
				<label for="form--name" class="uiField_label">
					Name:
				</label>
				<div class="uiField_content">
					<input
						id="form--name"
						type="text"
						name="name"
						value="#e4a( form.name )#"
						maxlength="50"
						class="uiInput"
					/>
				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Create Share
				</button>
				<a #ui.attrHref( "member.poems.shares", "poemID", poem.id )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
