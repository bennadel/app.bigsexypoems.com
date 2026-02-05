<cfsavecontent variable="request.response.body">
<cfoutput>

	<article f7a3b2 class="f7a3b2">

		<h1>
			Share Links
		</h1>

		<nav aria-labelledby="#ui.nextFieldId()#" class="uiPageNav">
			<span id="#ui.fieldId()#">
				Share Actions:
			</span>
			<ul>
				<li>
					<a #ui.attrHref( "member.poem.share.add", "poemID", poem.id )#>Add Share</a>
				</li>
				<cfif shares.len()>
					<li>
						<a #ui.attrHref( "member.poem.share.deleteAll", "poemID", poem.id )#>Delete All Shares</a>
					</li>
				</cfif>
			</ul>
		</nav>

		<cfif shares.len()>

			<div class="uiTable_scroller">

				<table x-table-row-linker class="uiTable">
				<thead>
					<tr>
						<th>
							Internal Name
						</th>
						<th>
							Public Note
						</th>
						<th>
							Public Link
						</th>
						<th align="center">
							Snapshot
						</th>
						<th align="center">
							Views
						</th>
						<th class="w-13">
							Last Viewed
						</th>
					</tr>
				</thead>
				<tbody>
				<cfloop array="#shares#" item="share">
					<tr>
						<td>
							<a #ui.attrHref( "member.poem.share.view", "shareID", share.id )# class="isRowLinker">#e( share.name )#</a>
						</td>
						<td>
							#e( share.noteMarkdown )#
						</td>
						<td class="isNoWrap">
							<cfset shareUrl = ui.externalUrlForParts( "share.poem", "shareID", share.id, "shareToken", share.token ) />

							<a href="#e4a( shareUrl )#" target="_blank">Public share link</a>
							&mdash;
							<button x-copy-to-clipboard="#e4a( shareUrl )#" class="uiButton isLink">Copy Link</button>
						</td>
						<td align="center">
							<cfif share.isSnapshot>
								<strong>Yes</strong>
								<cfif share.isOutdated>
									<span class="snapshotOutdated">
										Outdated
									</span>
								</cfif>
							</cfif>
						</td>
						<td align="center">
							<a #ui.attrHref( "member.poem.share.view", "shareID", share.id, "viewings" )#>#numberFormat( share.viewingCount )#</a>
						</td>
						<td class="isNoWrap">
							<cfif isDate( share.lastViewingAt )>
								#ui.userDate( share.lastViewingAt )#
							</cfif>
						</td>
					</tr>
				</cfloop>
				</tbody>
				</table>

			</div>

		</cfif>

		<cfif ! shares.len()>

			<p>
				You have no shares yet. <a #ui.attrHref( "member.poem.share.add", "poemID", poem.id )#>Generate a share link</a>.
			</p>

		</cfif>

	</article>

</cfoutput>
</cfsavecontent>
