<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<p>
			&larr;
			<a #ui.attrHref( "member.poems.shares", "poemID", poem.id )#>Back to Shares</a>
		</p>

		<cfif viewings.len()>

			<table border="1" cellspacing="5" cellpadding="10">
			<thead>
				<tr>
					<th>
						Viewed
					</th>
					<th>
						Country
					</th>
					<th>
						Region
					</th>
					<th>
						City
					</th>
				</tr>
			</thead>
			<tbody>
				<cfloop array="#viewings#" item="viewing">
					<tr>
						<td>
							#ui.userDate( viewing.createdAt )#
						</td>
						<td>
							<cfif viewing.ipCountry.len()>
								#e( viewing.ipCountry )#
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
							<cfif viewing.ipCity.len()>
								#e( viewing.ipCity )#
							<cfelse>
								<em>Unknown</em>
							</cfif>
						</td>
					</tr>
				</cfloop>
			</tbody>
			</table>

		</cfif>

		<cfif ! viewings.len()>
			<p>
				This share link has not yet been viewed.
			</p>
		</cfif>

	</article>

</cfoutput>
</cfsavecontent>
