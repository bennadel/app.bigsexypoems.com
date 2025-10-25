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
					<p class="uiField_description">
						This is the "plain text" editor. To get <mark>syllable counts</mark>, <mark>rhymes</mark>, and <mark>synonyms</mark>, <button type="submit" name="switchToComposer" value="true" class="uiButton isLink">use the <strong>poem composer</strong></button> &rarr;
					</p>

					<textarea
						id="form--content"
						name="content"
						maxlength="3000"
						class="uiTextarea"
						x-meta-enter-submit
					>#e( form.content )#</textarea>
				</div>
			</div>

			<div class="uiField">
				<label for="form--tagID" class="uiField_label">
					Tag:
				</label>
				<div class="uiField_content">
					<select id="form--tagID" name="tagID" class="uiSelect">
						<option value="0">&mdash; Coming soon &mdash;</option>
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
