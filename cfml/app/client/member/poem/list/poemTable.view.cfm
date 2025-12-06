<cfoutput>

	<div class="uiTable_scroller">

		<table x-table-row-linker class="uiTable">
		<thead>
			<tr>
				<th>
					Name
				</th>
				<th class="w-40">
					Preview
				</th>
				<th class="w-15">
					Collection
				</th>
				<th class="w-13">
					Updated
				</th>
			</tr>
		</thead>
		<tbody>
		<cfloop array="#attributes.poems#" item="poem">
			<tr>
				<td>
					<a #ui.attrHref( "member.poem.view", "poemID", poem.id )# class="isRowLinker">#e( poem.name )#</a>
				</td>
				<td>
					<cfmodule
						template="/client/_shared/tag/poemPreviewInTable.cfm"
						content="#poem.content#"
					/>
				</td>
				<td>
					<cfif poem.collection.id>
						<a #ui.attrHref( "member.collection.view", "collectionID", poem.collection.id )#>#e( poem.collection.name )#</a>
					</cfif>
				</td>
				<td class="isNoWrap">
					#ui.userDate( poem.updatedAt )#
				</td>
			</tr>
		</cfloop>
		</tbody>
		</table>

	</div>

</cfoutput>
