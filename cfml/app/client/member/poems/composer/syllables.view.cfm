<cfsavecontent variable="request.response.body">
<cfoutput>

	<ul>
		<cfloop array="#lineCounts#" item="lineCount">
			<li>
				<cfif lineCount>
					#e( lineCount )#
				</cfif>
			</li>
		</cfloop>
	</ul>

</cfoutput>
</cfsavecontent>
