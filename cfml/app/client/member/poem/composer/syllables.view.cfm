<cfsavecontent variable="request.response.body">
<cfoutput>

	<ul va5bd9 class="uiUnlist">
		<cfloop array="#lineCounts#" item="lineCount">
			<li>
				<cfif lineCount>
					#e( lineCount )#
				<cfelse>
					<span class="noSyllables">0</span>
				</cfif>
			</li>
		</cfloop>
	</ul>

</cfoutput>
</cfsavecontent>
