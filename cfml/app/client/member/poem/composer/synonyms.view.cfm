<cfsavecontent variable="request.response.body">
<cfoutput>

	<div x-data="sv7n3q.Synonyms" sv7n3q class="sv7n3q">

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
				No matching synonyms.
			</p>

		</cfif>

	</div>

</cfoutput>
</cfsavecontent>
