<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiFlow uiReadableWidth">

		<h1>
			#encodeForHtml( title )#
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
				<label for="form--name" class="uiField__label">
					Poem:
				</label>
				<div class="uiField__content">
					#encodeForHtml( poem.name )#
				</div>
			</div>

			<div class="uiField">
				<label for="form--name" class="uiField__label">
					Share:
				</label>
				<div class="uiField__content">
					#encodeForHtml( share.token )#
				</div>
			</div>

			<div class="uiField">
				<label for="form--isConfirmed" class="uiField__label">
					Confirm:
				</label>
				<div class="uiField__content">

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
