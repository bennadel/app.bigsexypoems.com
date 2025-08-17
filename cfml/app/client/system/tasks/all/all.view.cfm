<cfsavecontent variable="request.response.body">
<cfoutput>

	<h1>
		#e( title )#
	</h1>

	<p>
		Executed tasks: #numberFormat( taskCount )#
	</p>

	</cfoutput>
</cfsavecontent>
