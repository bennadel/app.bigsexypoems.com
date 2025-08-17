<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiFlow">

		<h1>
			Profile
		</h1>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			response="#errorResponse#">
		</cfmodule>

		<form method="post" action="#request.postBackAction#" class="uiReadableWidth">
			<cfmodule template="/client/_shared/tag/xsrf.cfm">

			<div class="uiField">
				<div class="uiField__label">
					Email:
				</div>
				<div class="uiField__content">
					#e( user.email )#
				</div>
			</div>

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
						maxlength="50"
						class="uiInput isFull"
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
