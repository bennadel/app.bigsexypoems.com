<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiReadableWidth">

		<h1>
			#e( title )#
		</h1>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			response="#errorResponse#">
		</cfmodule>

		<form method="post" action="#request.postBackAction#" x-prevent-double-submit>
			<cfmodule template="/client/_shared/tag/xsrf.cfm" />

			<div class="uiField">
				<span class="uiField_label">
					Poem:
				</span>
				<div class="uiField_content">
					#e( poem.name )#
				</div>
			</div>

			<div class="uiField">
				<label for="#ui.nextFieldId()#" class="uiField_label">
					Internal Name:
				</label>
				<div class="uiField_content">
					<p id="#ui.fieldId( "desc" )#" class="uiField_description">
						This name is <strong>for your eyes only</strong>; and is only helpful if you want to send your poem to different people with different notes. This name will help differentiate one share link from another.
					</p>

					<input
						id="#ui.fieldId()#"
						aria-describedby="#ui.fieldId( "desc" )#"
						type="text"
						name="name"
						value="#e4a( form.name )#"
						maxlength="50"
						autocomplete="off"
						x-keyed-focus
						class="uiInput"
					/>
				</div>
			</div>

			<div class="uiField">
				<label for="#ui.nextFieldId()#" class="uiField_label">
					Note:
				</label>
				<div class="uiField_content">
					<p id="#ui.fieldId( "desc" )#" class="uiField_description">
						This note is <strong>for your reader / recipient</strong> within the share experience. It gives you an opportunity to say something special; or, to introduce the poem in some way.
					</p>

					<textarea
						id="#ui.fieldId()#"
						aria-describedby="#ui.fieldId( "desc hint" )#"
						name="noteMarkdown"
						maxlength="1000"
						class="uiTextarea"
						x-meta-enter-submit
						x-auto-resize
					>#e( form.noteMarkdown )#</textarea>

					<p id="#ui.fieldId( "hint" )#" class="uiField_hint">
						The note uses <a href="##markdownDisclosure">Markdown</a> and supports basic formatting.
					</p>
				</div>
			</div>

			<div class="uiField">
				<label for="#ui.nextFieldId()#" class="uiField_label">
					Capture Snapshot:
				</label>
				<div class="uiField_content">
					<p class="uiField_description">
						When enabled, this share link will display a frozen version of your poem as it exists right now. Changes you make to the poem later will not appear in this share link (until the snapshot is explicitly refreshed).
					</p>

					<label class="uiHstack">
						<input
							id="#ui.fieldId()#"
							type="checkbox"
							name="isSnapshot"
							value="true"
							#ui.attrChecked( form.isSnapshot )#
							class="uiCheckbox"
						/>
						<span>
							Capture poem snapshot.
						</span>
					</label>
				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Create Share
				</button>
				<a #ui.attrHref( "member.poem.share", "poemID", poem.id )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>


	<cfmodule
		template="/client/_shared/tag/markdownDisclosure.cfm">
	</cfmodule>

</cfoutput>
</cfsavecontent>
