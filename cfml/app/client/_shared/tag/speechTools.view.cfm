<cfoutput>

	<details
		x-data="rifvd5.SpeechTools( '#e4j( inputID )#' )"
		rifvd5 #xClassToken# class="rifvd5 #xClass#">

		<summary rifvd5 class="summary">
			Speech Tools (Beta)
		</summary>

		<div rifvd5 class="uiHstack content">

			<select
				name="textToSpeechVoice"
				x-ref="voiceSelect"
				@input="handleVoice()"
				class="uiSelect">

				<option value="">
					Use default voice
				</option>

				<template x-for="( voice, i ) in voices">
					<option
						:value="voice.name"
						:selected="( voice.name === selectedName )"
						x-text="voice.name">
					</option>
				</template>
			</select>

			<button
				type="button"
				@click="handleToggle()"
				class="uiButton isNoWrap">

				<span x-text="( isSpeaking ? 'Stop Reading' : 'Read Poem' )"></span>
			</button>

		</div>
	</details>

</cfoutput>
