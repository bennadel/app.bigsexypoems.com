<cfsavecontent variable="request.response.body">
<cfoutput>

	<h1>
		#e( request.response.title )#
	</h1>

	<div tp3k8w #ui.attrClass({
		summary: true,
		isPassing: results.ok,
		isFailing: ! results.ok
		})#>
		<span>
			#numberFormat( results.passCount, "," )# passed.
		</span>

		<cfif results.failCount>
			<span>
				#numberFormat( results.failCount, "," )# failed.
			</span>
		</cfif>

		<cfif results.errorCount>
			<span>
				#numberFormat( results.errorCount, "," )# errors.
			</span>
		</cfif>
	</div>

	<cfif results.failures.len()>

		<h2>
			Failing Tests
		</h2>

		<table class="uiTable">
		<thead>
			<tr>
				<th class="w-1">
					Suite
				</th>
				<th class="w-1">
					Test
				</th>
				<th class="w-1">
					Type
				</th>
				<th>
					Extra
				</th>
			</tr>
		</thead>
		<tbody>
		<cfloop array="#results.failures#" item="entry">
			<tr>
				<td>
					<span title="#e4a( entry.suite )#">#e( entry.suite.listLast( "." ) )#</span>
				</td>
				<td>
					#e( entry.test )#
				</td>
				<td>
					<span tp3k8w #ui.attrClass({
						badge: true,
						isError: ( entry.type == "error" ),
						isFailure: ( entry.type != "error" )
						})#>
						#e( entry.type )#
					</span>
				</td>
				<td>
					#e( entry.message )#

					<cfif entry.detail.len()>
						<div class="uiSubtext">
							#e( entry.detail )#
						</div>
					</cfif>
				</td>
			</tr>
		</cfloop>
		</tbody>
		</table>

	</cfif>

	<cfif results.ok>

		<p>
			All tests passed.
		</p>

	</cfif>

</cfoutput>
</cfsavecontent>
