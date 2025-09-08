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

		<form method="post" action="#request.postBackAction#">
			<cfmodule template="/client/_shared/tag/xsrf.cfm">

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
						maxlength="255"
						autocomplete="off"
						class="uiInput"
					/>
				</div>
			</div>

			<div class="uiField">
				<label for="form--content" class="uiField_label">
					Content:
				</label>
				<div class="uiField_content">
					<textarea
						id="form--content"
						name="content"
						maxlength="3000"
						class="uiTextarea"
						x-meta-enter-submit
					>#e( form.content )#</textarea>
				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Create Poem
				</button>
				<a #ui.attrHref( "member.poems" )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
