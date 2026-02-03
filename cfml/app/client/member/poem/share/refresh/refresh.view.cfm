<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiReadableWidth">

		<h1>
			#e( title )#
		</h1>

		<p>
			This action will <strong>overwrite</strong> the existing snapshot with the current state of your poem. Compare the two versions below before confirming.
		</p>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			response="#errorResponse#">
		</cfmodule>

		<form method="post" action="#request.postBackAction#" x-prevent-double-submit>
			<cfmodule template="/client/_shared/tag/xsrf.cfm" />

			<div class="uiField">
				<span class="uiField_label">
					Current Snapshot:
				</span>
				<div class="uiField_content">
					<strong>#e( share.snapshotName )#</strong>
					<pre class="uiPre">#e( share.snapshotContent )#</pre>
				</div>
			</div>

			<div class="uiField">
				<span class="uiField_label">
					Live Poem (New Snapshot):
				</span>
				<div class="uiField_content">
					<strong>#e( poem.name )#</strong>
					<pre class="uiPre">#e( poem.content )#</pre>
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
