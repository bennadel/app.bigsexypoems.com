<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<p>
			<a #ui.attrHref( "member.poem.add" )#>Add Poem</a>
			|
			<a #ui.attrHref( "member.poem.global.share.list" )#>All Share Links</a>
		</p>

		<table class="uiTable">
		<thead>
			<tr>
				<th>
					Name
				</th>
				<th class="w-1">
					Tag
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
					<cfif poem.tag.id>
						<a #ui.attrHref( "member.poem.view", "poemID", poem.id )#>#e( poem.tag.name )#</a>
					</cfif>
				</td>
				<td class="isNoWrap">
					#ui.userDate( poem.updatedAt )#
				</td>
			</tr>
		</cfloop>
		</tbody>
		</table>

	</article>

</cfoutput>
</cfsavecontent>
