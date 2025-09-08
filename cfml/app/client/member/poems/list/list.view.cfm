<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<p>
			<a #ui.attrHref( "member.poems.add" )#>Add Poem</a>
		</p>

		<table border="1" cellspacing="5" cellpadding="10">
		<thead>
			<tr>
				<th>
					Name
				</th>
				<th>
					Created
				</th>
			</tr>
		</thead>
		<tbody>
			<cfloop array="#poems#" item="poem">
				<tr>
					<td>
						<a #ui.attrHref( "member.poems.view", "poemID", poem.id )#>#e( poem.name )#</a>
					</td>
					<td>
						#poem.createdAt.dateFormat( "mmmm d, yyyy" )#
					</td>
				</tr>
			</cfloop>
		</tbody>
		</table>

	</article>

</cfoutput>
</cfsavecontent>
