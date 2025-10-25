<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<p>
			<a #ui.attrHref( "member.tag.add" )#>Add Tag</a>
		</p>

		<table class="uiTable">
		<thead>
			<tr>
				<th>
					Name
				</th>
				<th>
					Slug
				</th>
				<th class="w-1">
					Created
				</th>
				<th class="w-1">
					<br />
				</th>
			</tr>
		</thead>
		<tbody>
		<cfloop array="#tags#" item="tag">
			<tr>
				<td>
					<a #ui.attrHref( "member.tag.edit", "tagID", tag.id )#>#e( tag.name )#</a>
				</td>
				<td>
					<a #ui.attrHref( "member.tag.edit", "tagID", tag.id )#>
						#e( tag.slug )#
					</a>
				</td>
				<td class="isNoWrap">
					#ui.userDate( tag.createdAt )#
				</td>
				<td class="isNoWrap">
					<div class="uiHstack">
						<a #ui.attrHref( "member.tag.edit", "tagID", tag.id )#>
							Edit
						</a>
						<a #ui.attrHref( "member.tag.delete", "tagID", tag.id )#>
							Delete
						</a>
					</div>
				</td>
			</tr>
		</cfloop>
		</tbody>
		</table>

	</article>

</cfoutput>
</cfsavecontent>
