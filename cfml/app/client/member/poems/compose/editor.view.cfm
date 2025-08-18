<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiFlow uiReadableWidth">

		<h1>
			#e( title )#
		</h1>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			response="#errorResponse#">
		</cfmodule>

		<form method="post" action="#request.postBackAction#">
			<cfmodule template="/client/_shared/tag/xsrf.cfm">

			<div class="uiField">
				<label for="form--name" class="uiField__label">
					Name:
				</label>
				<div class="uiField__content">
					<input
						id="form--name"
						type="text"
						name="name"
						value="#e4a( form.name )#"
						maxlength="255"
						class="uiInput isFull"
					/>
				</div>
			</div>

			<div class="uiField">
				<label for="form--content" class="uiField__label">
					Content:
				</label>
				<div class="uiField__content">
					<textarea
						id="form--content"
						name="content"
						maxlength="3000"
						class="uiTextarea"
					>#e( form.content )#</textarea>
				</div>
			</div>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Save Poem
				</button>
				<a #ui.attrHref( "member.poems.view", "poemID", poem.id )# class="uiButton isCancel">
					Cancel
				</a>
			</div>
		</form>

	</article>



	<div z6s31p class="wordTools">
		<section>
			<h2>
				BigSexy Rhymes
			</h2>
			<p>
				Find words that rhyme well with each other.
			</p>
			<form
				hx-get="#router.urlForParts( 'member.poems.compose.rhymes' )#"
				hx-target="next"
				hx-sync="this:replace"
				class="uiVstack">

				<div class="uiHstack">
					<input
						type="text"
						name="word"
						class="uiInput isFull"
					/>
					<select name="limit" class="uiSelect">
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
				<fieldset class="uiFieldset uiHstack isSparse">
					<legend class="uiLegend">
						Sort By:
					</legend>
					<label for="form--rhymes--groupBy--a" class="uiHstack isDense">
						<input
							id="form--rhymes--groupBy--a"
							type="radio"
							name="groupBy"
							value="syllableCount"
							class="uiRadio"
							checked
						/>
						Syllable Count
					</label>
					<label for="form--rhymes--groupBy--b" class="uiHstack isDense">
						<input
							id="form--rhymes--groupBy--b"
							type="radio"
							name="groupBy"
							value="typeOfSpeech"
							class="uiRadio"
						/>
						Type of Speech
					</label>
				</fieldset>
			</form>
			<div>
				<!--- Results shown here. --->
			</div>
		</section>

		<section>
			<h2>
				BigSexy Synonyms
			</h2>
			<p>
				Find words that mean roughly the same thing.
			</p>
			<form
				hx-get="#router.urlForParts( 'member.poems.compose.synonyms' )#"
				hx-target="next"
				hx-sync="this:replace"
				class="uiVstack">

				<div class="uiHstack">
					<input
						type="text"
						name="word"
						class="uiInput isFull"
					/>
					<select name="limit" class="uiSelect">
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
				<fieldset class="uiFieldset uiHstack isSparse">
					<legend class="uiLegend">
						Sort By:
					</legend>
					<label for="form--syllable--groupBy--a" class="uiHstack isDense">
						<input
							id="form--syllable--groupBy--a"
							type="radio"
							name="groupBy"
							value="syllableCount"
							class="uiRadio"
						/>
						Syllable Count
					</label>
					<label for="form--syllable--groupBy--b" class="uiHstack isDense">
						<input
							id="form--syllable--groupBy--b"
							type="radio"
							name="groupBy"
							value="typeOfSpeech"
							class="uiRadio"
							checked
						/>
						Type of Speech
					</label>
				</fieldset>
			</form>
			<div>
				<!--- Results shown here. --->
			</div>
		</section>		
	</div>


	<p>
		Rhymes and synonyms are provided by the <a href="https://www.datamuse.com/" target="_blank">Datamuse</a> API.
	</p>

</cfoutput>
</cfsavecontent>
