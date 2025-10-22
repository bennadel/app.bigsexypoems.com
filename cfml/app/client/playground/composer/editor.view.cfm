<cfsavecontent variable="request.response.body">
<cfoutput>

	<article r2mwmx>

		<div r2mwmx class="title">
			<h1>
				<a href="/" class="uiLink isSurprise"><span class="bigSexy">BigSexy</span>Poems</a>
			</h1>
			<p>
				<a href="/">Log in or Sign up</a>
			</p>
		</div>

		<form method="post" action="#request.postBackAction#">
			<cfmodule template="/client/_shared/tag/xsrf.cfm" />

			<label for="form--content" class="uiScreenReader">
				Content:
			</label>

			<div r2mwmx class="proser">
				<textarea
					id="form--content"
					name="content"
					data-default-value="#e4a( getDefaultPoem() )#"
					maxlength="3000"
					r2mwmx class="uiTextarea isLongTermFocus proser_content"
					x-data="r2mwmx.ProseContent( '#e4j( localStorageKey )#' )"
					@beforeunload.window="saveContent()"
					@input.debounce.200ms="saveContent()"
					@input.debounce.250ms="resizeContent()"
				></textarea>

				<!---
					Note: minor delay on LOAD trigger gives poem content time to load from
					the localStorage if it exists.
				--->
				<div
					hx-post="#router.urlForParts( 'playground.composer.syllables' )#"
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

	<div r2mwmx class="wordTools">
		<section>
			<h2>
				<span class="bigSexy">BigSexy</span>Rhymes
			</h2>

			<form
				hx-get="#router.urlForParts( 'playground.composer.rhymes' )#"
				hx-trigger="
					load,
					submit,
					input from:.isHtmxRhymesTrigger
				"
				hx-target="next .results"
				hx-sync="this:replace"
				class="uiVstack">

				<div class="uiHstack">
					<!---
						Todo: playing around with a default word to show how the feature
						works. I will likely remove this in the future. When doing so, be
						sure to remove the hx-trigger on the parent form.
					--->
					<input
						type="text"
						name="word"
						value="Big"
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
					<label for="form--rhymes--groupBy--a" class="uiHstack isTight">
						<input
							id="form--rhymes--groupBy--a"
							type="radio"
							name="groupBy"
							value="syllableCount"
							class="uiRadio isHtmxRhymesTrigger"
							checked
						/>
						Syllable Count
					</label>
					<label for="form--rhymes--groupBy--b" class="uiHstack isTight">
						<input
							id="form--rhymes--groupBy--b"
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
				<p>
					Find words that rhyme well with each other...
				</p>
			</div>
		</section>

		<section>
			<h2>
				<span class="bigSexy">BigSexy</span>Synonyms
			</h2>
			<form
				hx-get="#router.urlForParts( 'playground.composer.synonyms' )#"
				hx-trigger="
					load,
					submit,
					input from:.isHtmxSynonymsTrigger
				"
				hx-target="next .results"
				hx-sync="this:replace"
				class="uiVstack">

				<div class="uiHstack">
					<!---
						Todo: playing around with a default word to show how the feature
						works. I will likely remove this in the future. When doing so, be
						sure to remove the hx-trigger on the parent form.
					--->
					<input
						type="text"
						name="word"
						value="Sexy"
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
					<label for="form--synonyms--groupBy--a" class="uiHstack isTight">
						<input
							id="form--synonyms--groupBy--a"
							type="radio"
							name="groupBy"
							value="syllableCount"
							class="uiRadio isHtmxSynonymsTrigger"
						/>
						Syllable Count
					</label>
					<label for="form--synonyms--groupBy--b" class="uiHstack isTight">
						<input
							id="form--synonyms--groupBy--b"
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
				<p>
					Find words that mean roughly the same thing...
				</p>
			</div>
		</section>
	</div>

	<hr class="uiRule" />

	<section r2mwmx class="footerText">
		<p>
			<strong>BigSexy</strong>:
			<em>( /biɡ &##712;seks&##275;/ ) noun</em>.
			&mdash;
			Your muse. Your inspiration. The part of your soul that feels deeply, lives with abandon, and loves without limits.
		</p>

		<p>
			Rhymes, synonyms, and syllable counts are provided by the <a href="https://www.datamuse.com/" target="_blank">Datamuse</a> API.
		</p>

		<p>
			Hosting provided by <a href="https://www.xbytecloud.com/cloud" target="_blank">xByte Cloud</a>.
		</p>

		<p>
			Created by <a href="https://www.bennadel.com/" target="_blank">Ben Nadel</a>
			&copy; #year( now() )#
		</p>
	</section>

</cfoutput>
</cfsavecontent>
