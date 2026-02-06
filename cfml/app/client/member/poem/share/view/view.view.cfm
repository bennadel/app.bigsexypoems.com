<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<nav aria-labelledby="#ui.nextFieldId()#" class="uiPageNav">
			<span id="#ui.fieldId()#">
				Share Actions:
			</span>
			<ul>
				<li>
					<a #ui.attrHref( "member.poem.share.edit", "shareID", share.id )#>Edit</a>
				</li>
				<cfif share.isSnapshot>
					<li>
						<a #ui.attrHref( "member.poem.share.refresh", "shareID", share.id )#>Refresh Snapshot</a>
					</li>
				</cfif>
				<li>
					<a #ui.attrHref( "member.poem.share.delete", "shareID", share.id )#>Delete</a>
				</li>
			</ul>
		</nav>

		<dl class="uiProperties">
			<div>
				<dt>
					Poem:
				</dt>
				<dd>
					<a #ui.attrHref( "member.poem.view", "poemID", poem.id )#>#e( poem.name )#</a>
				</dd>
			</div>
			<div>
				<dt>
					Public Link:
				</dt>
				<dd>
					<cfset shareUrl = ui.externalUrlForParts( "share.poem", "shareID", share.id, "shareToken", share.token ) />

					<a href="#e4a( shareUrl )#" target="_blank"><mark>Preview public link</mark></a>
					&mdash;
					<button x-copy-to-clipboard="#e4a( shareUrl )#" class="uiButton isLink">Copy Link</button>
				</dd>
			</div>
			<div>
				<dt>
					Public Note:
				</dt>
				<dd>
					<cfif share.noteHtml.len()>
						#share.noteHtml#
					<cfelse>
						<em>None provided</em>
					</cfif>
				</dd>
			</div>
			<div>
				<dt>
					Snapshot:
				</dt>
				<dd>
					<cfif share.isSnapshot>
						<strong>Enabled</strong> &mdash; This share link displays a frozen version of your poem.
					<cfelse>
						<em>Disabled</em> &mdash; This share link displays the live version of your poem.
					</cfif>
				</dd>
			</div>
			<cfif isSnapshotStale>
				<div>
					<dt>
						Recent Changes:
					</dt>
					<dd>
						<cfmodule
							template="/client/_shared/tag/poemDiff.cfm"
							originalName="#share.snapshotName#"
							originalContent="#share.snapshotContent#"
							modifiedName="#poem.name#"
							modifiedContent="#poem.content#">
						</cfmodule>
					</dd>
				</div>
			</cfif>
		</dl>


		<h2 id="viewings">
			Recent Viewings
		</h2>

		<cfif viewings.len()>

			<div class="uiTable_scroller">

				<table class="uiTable">
				<thead>
					<tr>
						<th>
							Viewed
						</th>
						<th>
							City
						</th>
						<th>
							Region
						</th>
						<th>
							Country
						</th>
					</tr>
				</thead>
				<tbody>
				<cfloop array="#viewings#" item="viewing">
					<tr>
						<td>
							#ui.userDateTime( viewing.createdAt )#
						</td>
						<td>
							<cfif viewing.ipCity.len()>
								#e( viewing.ipCity )#
							<cfelse>
								<em>Unknown</em>
							</cfif>
						</td>
						<td>
							<cfif viewing.ipRegion.len()>
								#e( viewing.ipRegion )#
							<cfelse>
								<em>Unknown</em>
							</cfif>
						</td>
						<td>
							<cfif viewing.ipCountry.len()>
								#e( viewing.ipCountry )#
							<cfelse>
								<em>Unknown</em>
							</cfif>
						</td>
					</tr>
				</cfloop>
				</tbody>
				</table>

			</div>

		</cfif>

		<cfif ! viewings.len()>
			<p>
				This share link has not yet been viewed.
			</p>
		</cfif>

	</article>

</cfoutput>
</cfsavecontent>
