<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( poem.name )#
		</h1>

		<p>
			&larr; <a #ui.attrHref( "member.poem" )#>Back to Poems</a>
			|
			<a #ui.attrHref( "member.poem.composer", "poemID", poem.id )#>Composer</a>
			|
			<a #ui.attrHref( "member.poem.edit", "poemID", poem.id )#>Edit</a>
			|
			<a #ui.attrHref( "member.poem.delete", "poemID", poem.id )#>Delete</a>
			|
			<a #ui.attrHref( "member.poem.share", "poemID", poem.id )#>Share Links</a>
		</p>

		<hr />

		<pre>#e( poem.content )#</pre>

	</article>

</cfoutput>
</cfsavecontent>
