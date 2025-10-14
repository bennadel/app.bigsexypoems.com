<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<p>
			<a #ui.attrHref( "member.poem.add" )#>Add Poem</a>
			|
			<a #ui.attrHref( "member.poem.shareAll" )#>All Share Links</a>
		</p>

		<table class="uiTable">
		<thead>
			<tr>
				<th>
					Name
				</th>
				<th class="w-1">
					Created
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
						#poem.createdAt.dateFormat( "mmmm d, yyyy" )#
					</td>
				</tr>
			</cfloop>
		</tbody>
		</table>

	</article>

</cfoutput>
</cfsavecontent>
