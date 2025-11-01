<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiReadableWidth">

		<h1>
			#e( title )#
		</h1>

		<p>
			This action will delete the collection (but will <strong>not delete</strong> any of the poems contained within it).
		</p>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			response="#errorResponse#">
		</cfmodule>

		<form method="post" action="#request.postBackAction#" x-prevent-double-submit>
			<cfmodule template="/client/_shared/tag/xsrf.cfm" />

			<div class="uiField">
				<label class="uiField_label">
					Name:
				</label>
				<div class="uiField_content">
					#e( collection.name )#
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
				<button type="submit" class="uiButton isDanger">
					Delete Collection
				</button>
				<a #ui.attrHref( "member.collection.list" )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
