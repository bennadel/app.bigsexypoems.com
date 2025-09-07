<cfsavecontent variable="request.response.body">
<cfoutput>

	<ul class="uiUnlist">
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
