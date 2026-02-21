<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			Revisions
		</h1>

		<cfif revisions.len()>

			<div class="uiTable_scroller">

				<table x-table-row-linker class="uiTable">
				<thead>
					<tr>
						<th>
							Date
						</th>
						<th>
							Name
						</th>
						<th>
							Content
						</th>
					</tr>
				</thead>
				<tbody>
				<cfloop array="#revisions#" item="revision">
					<tr>
						<td class="isNoWrap">
							<a #ui.attrHref( "member.poem.revision.view", "revisionID", revision.id )# class="isRowLinker">#ui.userDateTime( revision.createdAt )#</a>
							<span class="uiSubtext">
								#ui.fromNow( revision.createdAt )#
							</span>
						</td>
						<td>
							#e( revision.name )#
						</td>
						<td>
							<cfmodule
								template="/client/member/_shared/tag/poemPreviewInTable.cfm"
								content="#revision.content#">
							</cfmodule>
						</td>
					</tr>
				</cfloop>
				</tbody>
				</table>

			</div>

		</cfif>

		<cfif ! revisions.len()>

			<p>
				This poem has no revisions yet.
			</p>

		</cfif>

	</article>

</cfoutput>
</cfsavecontent>
