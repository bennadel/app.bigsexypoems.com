<cfsavecontent variable="request.response.body">
<cfoutput>

	<cfif isSimpleValue( errorResponse )>

		Saved.

	<cfelse>

		An error occurred.

	</cfif>

</cfoutput>
</cfsavecontent>
