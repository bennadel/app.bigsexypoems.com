<cfsavecontent variable="request.response.body">
<cfoutput>

	<article d7r4f9 class="uiReadableWidth">

		<h1>
			#e( title )#
		</h1>

		<p>
			This action will <strong>overwrite</strong> the existing snapshot with the current state of your poem. Review the changes below before confirming.
		</p>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			response="#errorResponse#">
		</cfmodule>

		<form method="post" action="#request.postBackAction#" x-prevent-double-submit>
			<cfmodule template="/client/_shared/tag/xsrf.cfm" />

			<div class="uiField">
				<span class="uiField_label">
					Recent Changes:
				</span>
				<div class="uiField_content">

					<div class="diffView">
						<cfloop array="#diffOperations#" item="op">

							<span data-index="#e4a( op.index )#" data-type="#e4a( op.type )#" class="diffView_line">
								<cfloop array="#op.tokens#" item="token">
									<em data-type="#e4a( token.type )#">#e( token.value )#<br /></em>
								</cfloop>
							</span>

						</cfloop>
					</div>

				</div>
			</div>

			<div class="uiField">
				<label for="#ui.nextFieldId()#" class="uiField_label">
					Please Confirm:
				</label>
				<div class="uiField_content">
					<label class="uiHstack">
						<input
							id="#ui.fieldId()#"
							type="checkbox"
							name="isConfirmed"
							value="true"
							x-keyed-focus
							class="uiCheckbox"
						/>
						<span>
							I understand this will overwrite the existing snapshot.
						</span>
					</label>
				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Refresh Snapshot
				</button>
				<a #ui.attrHref( "member.poem.share.view", "shareID", share.id )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
