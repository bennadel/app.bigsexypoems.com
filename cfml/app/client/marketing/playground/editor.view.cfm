<cfsavecontent variable="request.response.body">
<cfoutput>

	<article r2mwmx>

		<h1>
			Poem Composer Playground
		</h1>

		<p>
			The composer provides tools to help unblock your creative process. Per-line syllable counts for rhyme schemes; rhyme and synonym look-ups; and a quick definition search. You can try the poem composer without an account. But in order to save the poem, track revisions, and create share-links, you must <a #ui.attrHref( "member" )#>log in</a> &mdash; for free, <em>woot woot</em>!
		</p>

		<form method="post" action="#request.postBackAction#">
			<cfmodule template="/client/_shared/tag/xsrf.cfm" />

			<label for="#ui.nextFieldId()#" class="uiScreenReader">
				Content:
			</label>

			<div r2mwmx class="proser">
				<textarea
					id="#ui.fieldId()#"
					name="content"
					data-default-value="#e4a( getDefaultPoem() )#"
					maxlength="3000"
					r2mwmx class="uiTextarea isLongTermFocus proser_content"
					x-data="r2mwmx.ProseContent( '#e4j( localStorageKey )#' )"
					x-auto-resize
					@beforeunload.window="saveContent()"
					@input.debounce.200ms="saveContent()"
				></textarea>

				<!---
					Note: minor delay on LOAD trigger gives poem content time to load from
					the localStorage if it exists.
				--->
				<div
					hx-post="#router.urlForParts( 'marketing.playground.syllables' )#"
					hx-trigger="
						load delay:50ms,
						input delay:1s from:previous textarea
					"
					hx-sync="this:replace"
					r2mwmx class="proser_counts">
					<!--- Syllable counts, populated by HTMX. --->
				</div>
			</div>

			<div r2mwmx class="buttons">
				<button type="submit" class="uiButton isSubmit">
					Save Poem to Account
				</button>

				<div r2mwmx class="autosaver">
					Your poem is cached in the browser's memory as you type.
				</div>
			</div>
		</form>

	</article>

	<div x-data="r2mwmx.WordTools" r2mwmx class="wordTools">
		<section r2mwmx class="rhymeTools" @app:word="handleRhyme( $event )">
			<h2>
				Rhymes
			</h2>

			<form
				hx-get="#router.urlForParts( 'marketing.playground.rhymes' )#"
				hx-trigger="
					submit,
					input from:.isHtmxRhymesTrigger
				"
				hx-target="next .results_content"
				hx-swap="show:.rhymeTools:top"
				hx-sync="this:replace"
				hx-indicator="next .uiIndicator"
				x-ref="rhymeForm"
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
					<label for="#ui.nextFieldId()#" class="uiScreenReader">
						Number of results:
					</label>
					<select
						id="#ui.fieldId()#"
						name="limit"
						class="uiSelect isAuto isHtmxRhymesTrigger">
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
				<div class="results_content" @htmx:before-swap="handleBeforeResults( $event )">
					<p>
						Find words that rhyme well with each other...
					</p>
				</div>
			</div>
		</section>

		<section r2mwmx class="synonymTools" @app:word="handleSynonym( $event )">
			<h2>
				Synonyms
			</h2>
			<form
				hx-get="#router.urlForParts( 'marketing.playground.synonyms' )#"
				hx-trigger="
					submit,
					input from:.isHtmxSynonymsTrigger
				"
				hx-target="next .results_content"
				hx-swap="show:.synonymTools:top"
				hx-sync="this:replace"
				hx-indicator="next .uiIndicator"
				x-ref="synonymForm"
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
					<label for="#ui.nextFieldId()#" class="uiScreenReader">
						Number of results:
					</label>
					<select
						id="#ui.fieldId()#"
						name="limit"
						class="uiSelect isAuto isHtmxSynonymsTrigger">
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
				<div class="results_content" @htmx:before-swap="handleBeforeResults( $event )">
					<p>
						Find words that mean roughly the same thing...
					</p>
				</div>
			</div>
		</section>

		<section r2mwmx class="definitionTools">
			<h2>
				Definitions
			</h2>
			<form
				hx-get="#router.urlForParts( 'marketing.playground.definitions' )#"
				hx-target="next .results_content"
				hx-swap="show:.definitionTool:top"
				hx-sync="this:replace"
				hx-indicator="next .uiIndicator"
				x-ref="definitionForm"
				class="uiHstack">

				<label for="#ui.nextFieldId()#" class="uiScreenReader">
					Word to search:
				</label>
				<input
					id="#ui.fieldId()#"
					type="text"
					name="word"
					class="uiInput"
				/>
				<button type="submit" class="uiButton">
					Search
				</button>
			</form>
			<div class="results">
				<span
					class="uiIndicator isDelayed">
				</span>
				<div class="results_content" @htmx:before-swap="handleBeforeResults( $event )">
					<p>
						Find definitions for a word...
					</p>
				</div>
			</div>
		</section>
	</div>

	<p r2mwmx class="datamuseAttribution">
		Rhymes, synonyms, definitions, and syllable counts are provided by the <a href="https://www.datamuse.com/" target="_blank">Datamuse</a> API.
	</p>

</cfoutput>
</cfsavecontent>
