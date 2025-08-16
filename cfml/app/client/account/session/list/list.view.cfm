<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiFlow uiReadableWidth">

		<h1>
			#encodeForHtml( title )#
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
					Started
				</th>
				<th>
					Last Activity
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
					#ui.userDate( entry.createdAt, "mmm d, yyyy" )#
				</td>
				<td>
					#ui.userDate( entry.lastRequestAt, "mmm d, yyyy" )#
				</td>
				<td>
					#numberFormat( entry.requestCount )#
				</td>
				<td>
					<a href="https://ipinfo.io/#encodeForUrl( entry.ipAddress )#" target="_blank">#encodeForHtml( entry.ipAddress )#</a>
				</td>
				<td>
					<cfif entry.isCurrent>
						Yes
					</cfif>
				</td>
				<td>
					<form method="post" action="#request.postBackAction#">
						<cfmodule template="/client/_shared/tag/xsrf.cfm">
						<input type="hidden" name="sessionID" value="#encodeForHtmlAttribute( entry.id )#" />

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

			<button type="submit" name="action" value="endAllSessions" class="uiButton isSubmit isDestructive">
				End All Sessions
			</button>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
