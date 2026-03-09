<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiReadableWidth">

		<h1>
			#e( title )#
		</h1>

		<p>
			This action will <strong><mark>permanently delete your account</mark></strong> along with all of your poems, collections, share links, etc. This action cannot be undone.
		</p>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			response="#errorResponse#">
		</cfmodule>

		<form method="post" action="#request.postBackAction#" x-prevent-double-submit>
			<cfmodule template="/client/_shared/tag/xsrf.cfm" />

			<div class="uiField">
				<span class="uiField_label">
					Email:
				</span>
				<div class="uiField_content">
					#e( user.email )#
				</div>
			</div>

			<div class="uiField">
				<span class="uiField_label">
					Name:
				</span>
				<div class="uiField_content">
					#e( user.name )#
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
							I understand that this action cannot be undone.
						</span>
					</label>

				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isDanger">
					Delete Account
				</button>
				<a #ui.attrHref( "member.profile.edit" )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
