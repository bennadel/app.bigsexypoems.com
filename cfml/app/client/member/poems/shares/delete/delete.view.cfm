<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiReadableWidth">

		<h1>
			#e( title )#
		</h1>

		<p>
			This action will delete the share link.
		</p>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			response="#errorResponse#">
		</cfmodule>

		<form method="post" action="#request.postBackAction#">
			<cfmodule template="/client/_shared/tag/xsrf.cfm">

			<div class="uiField">
				<label class="uiField_label">
					Poem:
				</label>
				<div class="uiField_content">
					#e( poem.name )#
				</div>
			</div>

			<div class="uiField">
				<label class="uiField_label">
					Share:
				</label>
				<div class="uiField_content">
					#e( share.token )#
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
					Delete Share
				</button>
				<a #ui.attrHref( "member.poems.shares", "poemID", poem.id )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
