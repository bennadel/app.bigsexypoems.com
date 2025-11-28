<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<nav aria-labelledby="#ui.nextFieldId()#" class="uiPageNav">
			<span id="#ui.fieldId()#">
				Collection Actions:
			</span>
			<ul>
				<li>
					<a #ui.attrHref( "member.collection.add" )#>Add Collection</a>
				</li>
			</ul>
		</nav>

		<cfif collections.len()>

			<table x-table-row-linker class="uiTable">
			<thead>
				<tr>
					<th>
						Name
					</th>
					<th class="w-1">
						Created
					</th>
					<th class="w-1">
						<br />
					</th>
				</tr>
			</thead>
			<tbody>
			<cfloop array="#collections#" item="collection">
				<tr>
					<td>
						<a #ui.attrHref( "member.collection.view", "collectionID", collection.id )# class="isRowLinker">#e( collection.name )#</a>
					</td>
					<td class="isNoWrap">
						#ui.userDate( collection.createdAt )#
					</td>
					<td>
						<div class="uiHstack">
							<a #ui.attrHref( "member.collection.edit", "collectionID", collection.id )#>
								Edit
							</a>
							<a #ui.attrHref( "member.collection.delete", "collectionID", collection.id )#>
								Delete
							</a>
						</div>
					</td>
				</tr>
			</cfloop>
			</tbody>
			</table>

		</cfif>

		<cfif ! collections.len()>

			<p>
				You have no collections yet. <a #ui.attrHref( "member.collection.add" )#>Create your first collection</a>.
			</p>

		</cfif>

	</article>

</cfoutput>
</cfsavecontent>
