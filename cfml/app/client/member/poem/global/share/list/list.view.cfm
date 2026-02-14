<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<cfif shares.len()>

			<div class="uiTable_scroller">

				<table x-table-row-linker class="uiTable">
				<thead>
					<tr>
						<th class="w-1">
							Last Viewed
						</th>
						<th class="w-30">
							Share
						</th>
						<th>
							Poem
						</th>
					</tr>
				</thead>
				<tbody>
				<cfloop array="#shares#" item="share">
					<tr>
						<td class="isNoWrap">
							<cfif isDate( share.lastViewingAt )>
								#ui.elemFromNow( share.lastViewingAt )#
							</cfif>
							<cfif share.viewingCount>
								<span class="uiSubtext">
									<a #ui.attrHref( "member.poem.share.view", "shareID", share.id, "viewings" )#>Total views: #numberFormat( share.viewingCount )#</a>
								</span>
							</cfif>
						</td>
						<td>
							<a #ui.attrHref( "member.poem.share.view", "shareID", share.id )# class="isRowLinker">#e( share.name )#</a>
							<cfif share.noteMarkdown.len()>
								<span class="uiSubtext">
									#e( truncate( share.noteMarkdown, 30 ) )#
								</span>
							</cfif>
						</td>
						<td>
							<a #ui.attrHref( "member.poem.view", "poemID", share.poem.id )#>#e( share.poem.name )#</a>
						</td>
					</tr>
				</cfloop>
				</tbody>
				</table>

			</div>

		</cfif>

		<cfif ! shares.len()>

			<p>
				You have no shares yet.
			</p>

		</cfif>

	</article>

</cfoutput>
</cfsavecontent>
