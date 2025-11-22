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

		<form method="post" action="#request.postBackAction#" x-prevent-double-submit x-keyed-focus>
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
						class="uiInput"
					/>
				</div>
			</div>

			<div class="uiField">
				<label for="#ui.nextFieldId()#" class="uiField_label">
					Slug:
				</label>
				<div class="uiField_content">
					<p id="#ui.fieldId( "desc" )#" class="uiField_description">
						This short text (20 characters max) will be rendered for brevity.
					</p>
					<input
						id="#ui.fieldId()#"
						aria-describedby="#ui.fieldId( "desc" )#"
						type="text"
						name="slug"
						value="#e4a( form.slug )#"
						maxlength="20"
						class="uiInput"
					/>
				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Create Tag
				</button>
				<a #ui.attrHref( "member.tag.list" )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
