<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiFlow uiReadableWidth">

		<h1>
			#e( title )#
		</h1>

		<p>
			This action will delete the poem as well as any data associated with this poem (such as share links).
		</p>

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
					#e( poem.name )#
				</div>
			</div>

			<div class="uiField">
				<label for="form--isConfirmed" class="uiField_label">
					Confirm:
				</label>
				<div class="uiField_content">

					<label for="form--isConfirmed" class="uiHstack">
						<input
							id="form--isConfirmed"
							type="checkbox"
							name="isConfirmed"
							value="true"
							class="uiCheckbox"
						/>
						<span id="form--isConfirmed--label">
							I understand that this action cannot be undone.
						</span>
					</label>

				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Delete Poem
				</button>
				<a #ui.attrHref( "member.poems.view", "poemID", poem.id )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
