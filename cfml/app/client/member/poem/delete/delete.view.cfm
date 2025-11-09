<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiReadableWidth">

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

		<form method="post" action="#request.postBackAction#" x-prevent-double-submit>
			<cfmodule template="/client/_shared/tag/xsrf.cfm" />

			<div class="uiField">
				<label class="uiField_label">
					Name:
				</label>
				<div class="uiField_content">
					#e( poem.name )#
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
							class="uiCheckbox"
						/>
						<span>
							I understand that this action cannot be undone.
						</span>
					</label>

				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isDanger">
					Delete Poem
				</button>
				<a #ui.attrHref( "member.poem.view", "poemID", poem.id )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
