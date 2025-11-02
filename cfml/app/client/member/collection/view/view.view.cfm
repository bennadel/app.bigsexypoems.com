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

		<h2>
			Poems In This Collection
		</h2>

		<cfif poems.len()>

			<table class="uiTable">
			<thead>
				<tr>
					<th>
						Name
					</th>
					<th class="w-1">
						Updated
					</th>
				</tr>
			</thead>
			<tbody>
			<cfloop array="#poems#" item="poem">
				<tr>
					<td>
						<a #ui.attrHref( "member.poem.view", "poemID", poem.id )#>#e( poem.name )#</a>
					</td>
					<td class="isNoWrap">
						#ui.userDate( poem.updatedAt )#
					</td>
				</tr>
			</cfloop>
			</tbody>
			</table>

		</cfif>

		<cfif ! poems.len()>

			<p>
				You have no poems in this collection yet.
				<!--- Todo: import some. --->
			</p>

		</cfif>

	</article>

</cfoutput>
</cfsavecontent>
