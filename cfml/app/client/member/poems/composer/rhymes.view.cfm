<cfsavecontent variable="request.response.body">
<cfoutput>

	<div pt70z1>

		<cfif groups.len()>

			<cfloop array="#groups#" item="group">

				<h3>
					#e( group.label )#
				</h3>

				<ul class="uiUnlist">
					<cfloop array="#group.results#" item="result">
						<li>
							#e( result.word )#.
						</li>
					</cfloop>
				</ul>

			</cfloop>

		</cfif>

		<cfif ! groups.len()>

			<p>
				No matching rhymes.
			</p>

		</cfif>

	</div>

</cfoutput>
</cfsavecontent>
