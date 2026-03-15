<cfsavecontent variable="request.response.body">
<cfoutput>

	<div wbo1mw class="wbo1mw">

		<cfif groups.len()>

			<cfloop array="#groups#" item="group">

				<h3>
					#e( group.label )#
				</h3>

				<ul>
					<cfloop array="#group.results#" item="result">
						<li>
							#e( result.definition )#
						</li>
					</cfloop>
				</ul>

			</cfloop>

		</cfif>

		<cfif ! groups.len()>

			<p>
				No matching definitions.
			</p>

		</cfif>

	</div>

</cfoutput>
</cfsavecontent>
