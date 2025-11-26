<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<cfif viewings.len()>

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

		</cfif>

		<cfif ! viewings.len()>
			<p>
				This share link has not yet been viewed.
			</p>
		</cfif>

	</article>

</cfoutput>
</cfsavecontent>
