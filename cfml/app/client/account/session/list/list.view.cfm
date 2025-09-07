<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiReadableWidth">

		<h1>
			#e( title )#
		</h1>

		<p>
			Your user is currently associated with the following sessions.
		</p>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			response="#errorResponse#">
		</cfmodule>

		<table border="1" cellpadding="10">
		<thead>
			<tr>
				<th>
					Last Activity
				</th>
				<th>
					Started
				</th>
				<th>
					Requests
				</th>
				<th>
					IP Address
				</th>
				<th>
					Current
				</th>
				<th>
					<br />
				</th>
			</tr>
		</thead>
		<cfloop array="#sessions#" item="entry">
			<tr>
				<td>
					#ui.userDate( entry.lastRequestAt, "mmm d, yyyy" )#
				</td>
				<td>
					#ui.userDate( entry.createdAt, "mmm d, yyyy" )#
				</td>
				<td>
					#numberFormat( entry.requestCount )#
				</td>
				<td>
					<a href="https://ipinfo.io/#e4u( entry.ipAddress )#" target="_blank">#e( entry.ipAddress )#</a>
				</td>
				<td>
					<cfif entry.isCurrent>
						Yes
					</cfif>
				</td>
				<td>
					<form method="post" action="#request.postBackAction#">
						<cfmodule template="/client/_shared/tag/xsrf.cfm">
						<input type="hidden" name="sessionID" value="#e4a( entry.id )#" />

						<button type="submit" name="action" value="endSession" class="uiButton">
							End Session
						</button>
					</form>
				</td>
			</tr>
		</cfloop>
		</table>

		<form method="post" action="#request.postBackAction#">
			<cfmodule template="/client/_shared/tag/xsrf.cfm">

			<button type="submit" name="action" value="endAllSessions" class="uiButton isDanger">
				End All Sessions
			</button>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
