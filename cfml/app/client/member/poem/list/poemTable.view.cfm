<cfoutput>

	<table class="uiTable">
	<thead>
		<tr>
			<th>
				Name
			</th>
			<th class="w-1">
				Collection
			</th>
			<th class="w-1">
				Updated
			</th>
		</tr>
	</thead>
	<tbody>
	<cfloop array="#attributes.poems#" item="poem">
		<tr>
			<td>
				<a #ui.attrHref( "member.poem.view", "poemID", poem.id )#>#e( poem.name )#</a>
			</td>
			<td class="isNoWrap">
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

</cfoutput>
