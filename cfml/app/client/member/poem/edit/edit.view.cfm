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
			<cfmodule template="/client/_shared/tag/hiddenSubmit.cfm" />

			<div class="uiField">
				<label for="form--name" class="uiField_label">
					Name:
					<span class="uiField_star">*</span>
				</label>
				<div class="uiField_content">
					<input
						id="form--name"
						type="text"
						name="name"
						value="#e4a( form.name )#"
						maxlength="255"
						autocomplete="off"
						class="uiInput"
					/>
				</div>
			</div>

			<div class="uiField">
				<label for="form--content" class="uiField_label">
					Content:
				</label>
				<div class="uiField_content">
					<p id="form--content--description" class="uiField_description">
						This is the "plain text" editor. To get <mark>syllable counts</mark>, <mark>rhymes</mark>, and <mark>synonyms</mark>, <button type="submit" name="switchToComposer" value="true" class="uiButton isLink">use the <strong>poem composer</strong></button> &rarr;
					</p>

					<textarea
						id="form--content"
						aria-describedby="form--content--description"
						name="content"
						maxlength="3000"
						class="uiTextarea"
						x-meta-enter-submit
					>#e( form.content )#</textarea>
				</div>
			</div>

			<div class="uiField">
				<label for="form--collectionID" class="uiField_label">
					Collection:
				</label>
				<div class="uiField_content">
					<p id="form--collectionID--description" class="uiField_description">
						A collection allows you to group poems together for categorization and sharing purposes.
					</p>

					<select
						id="form--collectionID"
						aria-describedby="form--collectionID--description"
						name="collectionID"
						class="uiSelect">
						<option value="0">- Select -</option>
						<cfloop array="#collections#" item="collection">
							<option
								value="#e4a( collection.id )#"
								#ui.attrSelected( form.collectionID eq collection.id )#>
								#e( collection.name )#
							</option>
						</cfloop>
					</select>
				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Update Poem
				</button>
				<a #ui.attrHref( "member.poem.view", "poemID", poem.id )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
