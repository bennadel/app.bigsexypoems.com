<cfsavecontent variable="request.response.body">
<cfoutput>

	<ul>
		<cfloop array="#counts#" item="count">
			<li>
				#e( count )#
			</li>
		</cfloop>
	</ul>

</cfoutput>
</cfsavecontent>
