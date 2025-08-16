<cfsavecontent variable="request.response.body">
<cfoutput>

	<h1>
		#encodeForHtml( title )#
	</h1>

	<p>
		Executed tasks: #numberFormat( taskCount )#
	</p>

	</cfoutput>
</cfsavecontent>
