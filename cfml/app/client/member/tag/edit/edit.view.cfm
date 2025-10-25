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
				<label for="form--slug" class="uiField_label">
					Slug:
				</label>
				<div class="uiField_content">
					<p class="uiField_description">
						This short text (20 characters max) will be rendered for brevity.
					</p>
					<input
						id="form--slug"
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
					Update Tag
				</button>
				<a #ui.attrHref( "member.tag.list" )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
