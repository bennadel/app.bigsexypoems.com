<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			Profile
		</h1>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			response="#errorResponse#">
		</cfmodule>

		<form
			method="post"
			action="#request.postBackAction#"
			x-prevent-double-submit
			class="uiReadableWidth">
			<cfmodule template="/client/_shared/tag/xsrf.cfm" />

			<div class="uiField">
				<div class="uiField_label">
					Email:
				</div>
				<div class="uiField_content">
					#e( user.email )#
				</div>
			</div>

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
						autocomplete="name"
						class="uiInput"
					/>
				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Save
				</button>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
