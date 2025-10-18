<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<p class="uiReadableWidth">
			Your user is currently associated with the following sessions.
		</p>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			response="#errorResponse#">
		</cfmodule>

		<table class="uiTable">
		<thead>
			<tr>
				<th>
					Last Activity
				</th>
				<th>
					Started
				</th>
				<th align="center">
					Requests
				</th>
				<th>
					IP Address
				</th>
				<th align="center">
					Current
				</th>
				<th class="w-1">
					<br />
				</th>
			</tr>
		</thead>
		<tbody>
		<cfloop array="#sessions#" item="element">
			<tr>
				<td>
					#ui.userDate( element.lastRequestAt, "mmm d, yyyy" )#
				</td>
				<td>
					#ui.userDate( element.createdAt, "mmm d, yyyy" )#
				</td>
				<td align="center">
					#numberFormat( element.requestCount )#
				</td>
				<td>
					<a href="https://ipinfo.io/#e4u( element.ipAddress )#" target="_blank">#e( element.ipAddress )#</a>
				</td>
				<td align="center">
					<cfif element.isCurrent>
						<strong>Yes</strong>
					</cfif>
				</td>
				<td align="center" class="isNoWrap">
					<form method="post" action="#request.postBackAction#" x-prevent-double-submit>
						<cfmodule template="/client/_shared/tag/xsrf.cfm" />
						<input type="hidden" name="sessionID" value="#e4a( element.id )#" />

						<button
							type="submit"
							name="action"
							value="endSession"
							class="uiButton isLink isDanger">
							<cfif element.isCurrent>
								<strong>Log Out</strong>
							<cfelse>
								End Session
							</cfif>
						</button>
					</form>
				</td>
			</tr>
		</cfloop>
		</tbody>
		</table>

		<form method="post" action="#request.postBackAction#" x-prevent-double-submit>
			<cfmodule template="/client/_shared/tag/xsrf.cfm" />

			<button type="submit" name="action" value="endAllSessions" class="uiButton isDanger">
				End All Sessions
			</button>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
