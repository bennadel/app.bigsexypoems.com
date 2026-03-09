<cfsavecontent variable="request.response.body">
<cfoutput>

	<h1>
		#e( request.response.title )#
	</h1>

	<div tp3k8w #ui.attrClass({
		summary: true,
		isPassing: results.pass,
		isFailing: ! results.pass
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

		<span>
			Duration: #numberFormat( duration, "," )#ms.
		</span>
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
						isError: ( entry.failure.code == "error" ),
						isFailure: ( entry.failure.code != "error" )
						})#>
						#e( entry.failure.code )#
					</span>
				</td>
				<td>
					<cfif entry.failure.message.len()>
						#e( entry.failure.message )#
					<cfelse>
						<em class="uiSubtext">#e( entry.failure.type )#</em>
					</cfif>

					<cfif entry.failure.detail.len()>
						<div class="uiSubtext">
							#e( entry.failure.detail )#
						</div>
					</cfif>
				</td>
			</tr>
		</cfloop>
		</tbody>
		</table>

	</cfif>

	<cfif results.pass>

		<p>
			All tests passed.
		</p>

	</cfif>


	<h2>
		Test Manifest
	</h2>

	<p>
		<a #ui.attrHref( "dev.test.spec.cleanup" )#">Clean up test data</a> and optimize tables.
	</p>

	<ul>
		<cfloop array="#results.manifest#" item="entry">
			<li>
				#e( entry.suite )# :: #e( entry.test )# &rarr;

				<cfif entry.pass>
					ok
				<cfelse>
					<strong>fail</strong>
				</cfif>

				(#numberFormat( entry.duration, "," )#ms)
			</li>
		</cfloop>
	</ul>

</cfoutput>
</cfsavecontent>
