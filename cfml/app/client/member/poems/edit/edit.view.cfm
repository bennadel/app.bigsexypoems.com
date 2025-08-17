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
				<label for="form--name" class="uiField__label">
					Name:
				</label>
				<div class="uiField__content">
					<input
						id="form--name"
						type="text"
						name="name"
						value="#e4a( form.name )#"
						maxlength="255"
						class="uiInput isFull"
					/>
				</div>
			</div>

			<div class="uiField">
				<label for="form--content" class="uiField__label">
					Content:
				</label>
				<div class="uiField__content">
					<textarea
						id="form--content"
						name="content"
						maxlength="3000"
						class="uiTextarea"
					>#e( form.content )#</textarea>
				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Update Poem
				</button>
				<a #ui.attrHref( "member.poems.view", "poemID", poem.id )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
