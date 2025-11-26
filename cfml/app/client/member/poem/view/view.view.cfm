<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( poem.name )#
		</h1>

		<cfif maybeCollection.exists>
			<p>
				<strong>Collection:</strong>
				<a #ui.attrHref( "member.collection.view", "collectionID", maybeCollection.value.id )#>#e( maybeCollection.value.name )#</a>
			</p>
		</cfif>

		<p>
			<a #ui.attrHref( "member.poem.composer", "poemID", poem.id )#>Composer</a>
			|
			<a #ui.attrHref( "member.poem.edit", "poemID", poem.id )#>Edit</a>
			|
			<a #ui.attrHref( "member.poem.delete", "poemID", poem.id )#>Delete</a>
			|
			<a #ui.attrHref( "member.poem.share", "poemID", poem.id )#>Share Links</a>
		</p>

		<hr />

		<ul vyxlrv class="lines">
			<cfloop array="#lines#" item="line">
				<li>
					#e( line )#<br />
				</li>
			</cfloop>
		</ul>

	</article>

</cfoutput>
</cfsavecontent>
