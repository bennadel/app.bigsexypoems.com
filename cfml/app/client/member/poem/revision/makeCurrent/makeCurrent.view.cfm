<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiReadableWidth">

		<h1>
			#e( title )#
		</h1>

		<p>
			This action will <strong>overwrite</strong> the current poem with the content from this revision. Review the changes below before confirming.
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

					<cfmodule
						template="/client/member/_shared/tag/poemDiff.cfm"
						originalHeader="Revision"
						originalName="#revision.name#"
						originalContent="#revision.content#"
						modifiedHeader="Live Poem"
						modifiedName="#poem.name#"
						modifiedContent="#poem.content#">
					</cfmodule>

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
							I understand that the current poem content will be overwritten.
						</span>
					</label>

				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Restore Revision
				</button>
				<a #ui.attrHref( "member.poem.revision.view", "revisionID", revision.id )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
