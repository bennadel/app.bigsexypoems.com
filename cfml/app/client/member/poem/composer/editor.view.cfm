<cfsavecontent variable="request.response.body">
<cfoutput>

	<article z6s31p>

		<h1>
			#e( title )#
		</h1>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			response="#errorResponse#">
		</cfmodule>

		<form method="post" action="#request.postBackAction#" x-prevent-double-submit>
			<cfmodule template="/client/_shared/tag/xsrf.cfm" />

			<label for="#ui.nextFieldId()#" class="uiScreenReader">
				Name:
			</label>

			<input
				id="#ui.fieldId()#"
				type="text"
				name="name"
				value="#e4a( form.name )#"
				maxlength="255"
				autocomplete="off"
				z6s31p class="uiInput name"
			/>

			<label for="form--content" class="uiScreenReader">
				Content:
			</label>

			<div z6s31p class="proser">
				<textarea
					x-data="z6s31p.ProseContent"
					id="form--content"
					name="content"
					maxlength="3000"
					z6s31p class="uiTextarea isLongTermFocus proser_content"
					x-meta-enter-submit
					@input.debounce.250ms="resizeContent()"
				>#e( form.content )#</textarea>

				<div
					hx-post="#router.urlForParts( 'member.poem.composer.syllables' )#"
					hx-trigger="load, input delay:1s from:previous textarea"
					hx-sync="this:replace"
					z6s31p class="proser_counts">
					<!--- Syllable counts, populated by HTMX. --->
				</div>
			</div>

			<div z6s31p class="buttons">
				<button type="submit" class="uiButton isSubmit">
					Save Poem
				</button>

				<a #ui.attrHref( "member.poem.view", "poemID", poem.id )# class="uiButton isCancel">
					Back to Detail
				</a>

				<div z6s31p class="autosaver">
					<span>
						Poem will automatically
						<button
							type="button"
							hx-post="#router.urlForParts( 'member.poem.composer.saveInBackground', 'poemID', poem.id )#"
							hx-trigger="
								click,
								input delay:1s from:##form--content
							"
							hx-target=".autosaver_status"
							hx-sync="this:replace"
							hx-indicator=".autosaver"
							class="uiButton isLink">
							save
						</button>
						as you type:
					</span>
					<span z6s31p class="autosaver_status">
						Saved.
					</span>
					<span z6s31p class="autosaver_indicator">
						Saving....
					</span>
				</div>
			</div>
		</form>

		<cfmodule
			template="/client/_shared/tag/speechTools.cfm"
			inputID="form--content"
			xClassToken="z6s31p"
			xClass="speechTools"
		/>

	</article>

	<div z6s31p class="wordTools">
		<section>
			<h2>
				<span class="bigSexy">BigSexy</span>Rhymes
			</h2>

			<form
				hx-get="#router.urlForParts( 'member.poem.composer.rhymes' )#"
				hx-trigger="
					submit,
					input from:.isHtmxRhymesTrigger
				"
				hx-target="next .results_content"
				hx-sync="this:replace"
				hx-indicator="next .uiIndicator"
				class="uiVstack">

				<div class="uiHstack">
					<label for="#ui.nextFieldId()#" class="uiScreenReader">
						Word to search:
					</label>
					<input
						id="#ui.fieldId()#"
						type="text"
						name="word"
						class="uiInput"
					/>
					<select name="limit" class="uiSelect isAuto isHtmxRhymesTrigger">
						<option value="50">50 results</option>
						<option value="100" selected>100 results</option>
						<option value="150">150 results</option>
						<option value="200">200 results</option>
						<option value="300">300 results</option>
						<option value="400">400 results</option>
						<option value="500">500 results</option>
					</select>
					<button type="submit" class="uiButton">
						Search
					</button>
				</div>
				<fieldset class="uiFieldset uiHstack isLoose">
					<legend class="uiLegend">
						Sort By:
					</legend>
					<label class="uiHstack isTight">
						<input
							type="radio"
							name="groupBy"
							value="syllableCount"
							class="uiRadio isHtmxRhymesTrigger"
							checked
						/>
						Syllable Count
					</label>
					<label class="uiHstack isTight">
						<input
							type="radio"
							name="groupBy"
							value="typeOfSpeech"
							class="uiRadio isHtmxRhymesTrigger"
						/>
						Type of Speech
					</label>
				</fieldset>
			</form>
			<div class="results">
				<span
					class="uiIndicator isDelayed">
				</span>
				<div class="results_content">
					<p>
						Find words that rhyme well with each other...
					</p>
				</div>
			</div>
		</section>

		<section>
			<h2>
				<span class="bigSexy">BigSexy</span>Synonyms
			</h2>
			<form
				hx-get="#router.urlForParts( 'member.poem.composer.synonyms' )#"
				hx-trigger="
					submit,
					input from:.isHtmxSynonymsTrigger
				"
				hx-target="next .results_content"
				hx-sync="this:replace"
				hx-indicator="next .uiIndicator"
				class="uiVstack">

				<div class="uiHstack">
					<label for="#ui.nextFieldId()#" class="uiScreenReader">
						Word to search:
					</label>
					<input
						id="#ui.fieldId()#"
						type="text"
						name="word"
						class="uiInput"
					/>
					<select name="limit" class="uiSelect isAuto isHtmxSynonymsTrigger">
						<option value="50">50 results</option>
						<option value="100" selected>100 results</option>
						<option value="150">150 results</option>
						<option value="200">200 results</option>
						<option value="300">300 results</option>
						<option value="400">400 results</option>
						<option value="500">500 results</option>
					</select>
					<button type="submit" class="uiButton">
						Search
					</button>
				</div>
				<fieldset class="uiFieldset uiHstack isLoose">
					<legend class="uiLegend">
						Sort By:
					</legend>
					<label class="uiHstack isTight">
						<input
							type="radio"
							name="groupBy"
							value="syllableCount"
							class="uiRadio isHtmxSynonymsTrigger"
						/>
						Syllable Count
					</label>
					<label class="uiHstack isTight">
						<input
							type="radio"
							name="groupBy"
							value="typeOfSpeech"
							class="uiRadio isHtmxSynonymsTrigger"
							checked
						/>
						Type of Speech
					</label>
				</fieldset>
			</form>
			<div class="results">
				<span
					class="uiIndicator isDelayed">
				</span>
				<div class="results_content">
					<p>
						Find words that mean roughly the same thing...
					</p>
				</div>
			</div>
		</section>
	</div>

	<hr class="uiRule" />

	<p>
		Rhymes, synonyms, and syllable counts are provided by the <a href="https://www.datamuse.com/" target="_blank">Datamuse</a> API.
	</p>

	<p>
		Enjoying the poem composer? <a #ui.attrHref( "playground" )# target="_blank">Share the public playground version</a> with a friend (no sign up required). &##x1F970;
	</p>

</cfoutput>
</cfsavecontent>
