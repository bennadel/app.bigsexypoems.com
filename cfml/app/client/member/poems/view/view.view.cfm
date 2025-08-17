<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiFlow">

		<h1>
			#e( poem.name )#
		</h1>

		<p>
			&larr; <a #ui.attrHref( "member.poems" )#>Back to Poems</a>
			|
			<a #ui.attrHref( "member.poems.edit", "poemID", poem.id )#>Edit</a>
			|
			<a #ui.attrHref( "member.poems.delete", "poemID", poem.id )#>Delete</a>
			|
			<a #ui.attrHref( "member.poems.shares", "poemID", poem.id )#>Share Links</a>
		</p>

		<hr />

		<pre>#e( poem.content )#</pre>

	</article>

</cfoutput>
</cfsavecontent>
