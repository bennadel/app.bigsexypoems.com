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
				<span class="uiField_label">
					Poem:
				</span>
				<div class="uiField_content">
					#e( poem.name )#
				</div>
			</div>

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
						autocomplete="off"
						class="uiInput"
					/>
				</div>
			</div>

			<div class="uiField">
				<label for="form--noteMarkdown" class="uiField_label">
					Note:
				</label>
				<div class="uiField_content">
					<textarea
						id="form--noteMarkdown"
						aria-describedby="form--noteMarkdown--description"
						name="noteMarkdown"
						maxlength="1000"
						class="uiTextarea"
					>#e( form.noteMarkdown )#</textarea>

					<p id="form--noteMarkdown--description" class="uiHint">
						The note uses Markdown and supports basic formatting.
					</p>
				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Update Share
				</button>
				<a #ui.attrHref( "member.poems.shares", "poemID", poem.id )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
