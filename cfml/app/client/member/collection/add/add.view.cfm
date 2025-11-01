<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiReadableWidth">

		<h1>
			#e( title )#
		</h1>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			response="#errorResponse#">
		</cfmodule>

		<form method="post" action="#request.postBackAction#" x-prevent-double-submit>
			<cfmodule template="/client/_shared/tag/xsrf.cfm" />

			<div class="uiField">
				<label for="form--name" class="uiField_label">
					Name:
					<span class="uiField_star">*</span>
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
				<label for="form--descriptionMarkdown" class="uiField_label">
					Description:
				</label>
				<div class="uiField_content">
					<textarea
						id="form--descriptionMarkdown"
						aria-describedby="form--descriptionMarkdown--hint"
						name="descriptionMarkdown"
						maxlength="500"
						class="uiTextarea"
						x-meta-enter-submit
					>#e( form.descriptionMarkdown )#</textarea>

					<p id="form--descriptionMarkdown--hint" class="uiField_hint">
						The description uses <a href="##markdownDisclosure">Markdown</a> and supports basic formatting.
					</p>
				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Create Collection
				</button>
				<a #ui.attrHref( "member.collection.list" )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>


	<cfmodule
		template="/client/_shared/tag/markdownDisclosure.cfm">
	</cfmodule>

</cfoutput>
</cfsavecontent>
