<cfoutput>

	<details
		x-data="kg8mkb.MarkdownDisclosure"
		kg8mkb #attributes.xClassToken#
		class="kg8mkb #attributes.xClass# uiReadableWidth">

		<summary
			id="#attributes.xID#"
			@load.window="applyHashEventToSummary()"
			@hashchange.window="applyHashEventToSummary()"
			class="uiFocusForcer">
			Markdown syntax tips
		</summary>
		<section aria-labeledby="#attributes.xID#" kg8mkb class="content">

			<p>
				<a href="https://www.markdownguide.org/basic-syntax/" target="_blank">Markdown is a writing syntax</a> that lets you to add simple formatting using plain-text notation.
			</p>

			<ul>
				<li>
					<b>**bold**</b>
				</li>
				<li>
					<i>_italic_</i>
				</li>
			</ul>

		</section>
	</details>

</cfoutput>
