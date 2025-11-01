<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( collection.name )#
		</h1>

		<p>
			&larr; <a #ui.attrHref( "member.collection" )#>Back to Collections</a>
			|
			<a #ui.attrHref( "member.collection.edit", "collectionID", collection.id )#>Edit</a>
			|
			<a #ui.attrHref( "member.collection.delete", "collectionID", collection.id )#>Delete</a>
		</p>

		<hr />

		<cfif collection.descriptionHtml.len()>
			#collection.descriptionHtml#
		</cfif>

		<p>
			More coming soon....
		</p>

	</article>

</cfoutput>
</cfsavecontent>
