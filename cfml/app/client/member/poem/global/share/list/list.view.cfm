<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<p>
			&larr; <a #ui.attrHref( "member.poem" )#>Back to Poems</a>
		</p>

		<hr />

		<table class="uiTable">
		<thead>
			<tr>
				<th>
					Poem
				</th>
				<th>
					Share Name
				</th>
				<th>
					Share Note
				</th>
				<th>
					Views
				</th>
				<th class="w-1">
					Created
				</th>
			</tr>
		</thead>
		<cfloop array="#poems#" item="poem">
			<tbody>
			<cfloop array="#poem.shares#" item="share" index="shareIndex">
				<tr>
					<cfif ( shareIndex eq 1 )>
						<td valign="top" rowspan="#poem.shares.len()#">
							<a #ui.attrHref( "member.poem.view", "poemID", poem.id )#><strong>#e( poem.name )#</strong></a>
						</td>
					</cfif>
					<td>
						<a #ui.attrHref( "member.poem.share.list", "poemID", poem.id )#>#e( coalesceTruthy( share.name, "Unnamed" ) )#</a>
					</td>
					<td>
						#e( truncate( share.noteMarkdown, 30 ) )#
					</td>
					<td>
						<cfif share.viewingCount>
							<a #ui.attrHref( "member.poem.share.viewing.list", "shareID", share.id )#>#numberFormat( share.viewingCount )#</a>
						</cfif>
					</td>
					<td class="isNoWrap">
						#ui.userDate( share.createdAt )#
					</td>
				</tr>
			</cfloop>
			</tbody>
		</cfloop>
		</table>

	</article>

</cfoutput>
</cfsavecontent>
