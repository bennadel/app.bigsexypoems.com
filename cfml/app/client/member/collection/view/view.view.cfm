<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( collection.name )#
		</h1>

		<nav aria-labelledby="#ui.nextFieldId()#" class="uiPageNav">
			<span id="#ui.fieldId()#">
				Collection Actions:
			</span>
			<ul>
				<li>
					<a #ui.attrHref( "member.collection.edit", "collectionID", collection.id )#>Edit</a>
				</li>
				<li>
					<a #ui.attrHref( "member.collection.delete", "collectionID", collection.id )#>Delete</a>
				</li>
			</ul>
		</nav>

		<cfif collection.descriptionHtml.len()>
			#collection.descriptionHtml#
		</cfif>

		<h2>
			Poems In This Collection
		</h2>

		<cfif poems.len()>

			<div class="uiTable_scroller">

				<table x-table-row-linker class="uiTable">
				<thead>
					<tr>
						<th>
							Name
						</th>
						<th class="w-50">
							Preview
						</th>
						<th class="w-13">
							Updated
						</th>
					</tr>
				</thead>
				<tbody>
				<cfloop array="#poems#" item="poem">
					<tr>
						<td>
							<a #ui.attrHref( "member.poem.view", "poemID", poem.id )# class="isRowLinker">#e( poem.name )#</a>
						</td>
						<td>
							<cfmodule
								template="/client/member/_shared/tag/poemPreviewInTable.cfm"
								content="#poem.content#"
							/>
						</td>
						<td class="isNoWrap">
							#ui.userDate( poem.updatedAt )#
						</td>
					</tr>
				</cfloop>
				</tbody>
				</table>

			</div>

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
