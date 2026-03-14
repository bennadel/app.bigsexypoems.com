<cfsavecontent variable="request.response.body">
<cfoutput>

	<div x-data="ht6w2p.Rhymes" ht6w2p class="ht6w2p">

		<cfif groups.len()>

			<cfloop array="#groups#" item="group">

				<h3>
					#e( group.label )#
				</h3>

				<ul class="uiUnlist">
					<cfloop array="#group.results#" item="result">
						<li>
							<a role="button" @click="handleClick( $event )">#e( result.word )#</a>.
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
