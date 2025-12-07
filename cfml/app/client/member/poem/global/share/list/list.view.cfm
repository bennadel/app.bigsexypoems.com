<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<cfif poems.len()>

			<div class="uiTable_scroller">

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
						<th align="center">
							Views
						</th>
						<th class="w-1">
							Last Viewed
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
								<a #ui.attrHref( "member.poem.share.view", "shareID", share.id )#>#e( coalesceTruthy( share.name, "Unnamed" ) )#</a>
							</td>
							<td>
								#e( truncate( share.noteMarkdown, 30 ) )#
							</td>
							<td align="center">
								<cfif share.viewingCount>
									<a #ui.attrHref( "member.poem.share.view", "shareID", share.id, "viewings" )#>#numberFormat( share.viewingCount )#</a>
								</cfif>
							</td>
							<td class="isNoWrap">
								<cfif isDate( share.lastViewingAt )>
									#ui.userDate( share.lastViewingAt )#
								</cfif>
							</td>
						</tr>
					</cfloop>
					</tbody>
				</cfloop>
				</table>

			</div>

		</cfif>

		<cfif ! poems.len()>

			<p>
				You have no shares yet.
			</p>

		</cfif>

	</article>

</cfoutput>
</cfsavecontent>
