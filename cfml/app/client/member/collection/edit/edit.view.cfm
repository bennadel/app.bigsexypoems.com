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
				<label for="#ui.nextFieldId()#" class="uiField_label">
					Name:
					<span class="uiField_star">*</span>
				</label>
				<div class="uiField_content">
					<input
						id="#ui.fieldId()#"
						type="text"
						name="name"
						value="#e4a( form.name )#"
						maxlength="50"
						autocomplete="off"
						x-keyed-focus
						class="uiInput"
					/>
				</div>
			</div>

			<div class="uiField">
				<label for="#ui.nextFieldId()#" class="uiField_label">
					Description:
				</label>
				<div class="uiField_content">
					<textarea
						id="#ui.fieldId()#"
						aria-describedby="#ui.fieldId( "hint" )#"
						name="descriptionMarkdown"
						maxlength="500"
						class="uiTextarea"
						x-meta-enter-submit
						x-auto-resize
					>#e( form.descriptionMarkdown )#</textarea>

					<p id="#ui.fieldId( "hint" )#" class="uiField_hint">
						The description uses <a href="##markdownDisclosure">Markdown</a> and supports basic formatting.
					</p>
				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Update Collection
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
