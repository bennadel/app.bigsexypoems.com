<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			Share Links
		</h1>

		<p>
			&larr;
			<a #ui.attrHref( "member.poems.view", "poemID", poem.id )#>Back to Poem</a>
			|
			<a #ui.attrHref( "member.poems.shares.add", "poemID", poem.id )#>Add share links</a>
		</p>

		<table border="1" cellspacing="5" cellpadding="10">
		<thead>
			<tr>
				<th>
					Modified
				</th>
				<th>
					Link
				</th>
				<th>
					Internal Name
				</th>
				<th>
					Note
				</th>
				<th>
					Actions
				</th>
			</tr>
		</thead>
		<tbody>
		<cfloop array="#shares#" item="share">
			<tr>
				<td>
					#ui.userDate( share.updatedAt )#
				</td>
				<td>
					<a #ui.attrHref( "share.poem", "shareID", share.id, "shareToken", share.token )# target="_blank">Public share link (#e( share.id )#)</a>
				</td>
				<td>
					#e( share.name )#
				</td>
				<td>
					#e( share.noteMarkdown )#
				</td>
				<td>
					<div class="uiHstack">
						<a #ui.attrHref( "member.poems.shares.edit", "shareID", share.id )#>
							Edit
						</a>
						<form method="post" #ui.attrAction( "member.poems.shares.delete", "shareID", share.id )#>
							<cfmodule template="/client/_shared/tag/xsrf.cfm">
							<input type="hidden" name="isConfirmed" value="true" />
							<!--- <input type="hidden" name="formToken" value="#e4a( formToken )#" /> --->
							<button type="submit" class="uiButton">
								Revoke
							</button>
						</form>
					</div>
				</td>
			</tr>
		</cfloop>
		</tbody>
		</table>

		<cfif shares.len()>
			<p>
				<a #ui.attrHref( "member.poems.shares.deleteAll", "poemID", poem.id )#>Delete all share links</a>
			</p>
		</cfif>

	</article>

</cfoutput>
</cfsavecontent>
