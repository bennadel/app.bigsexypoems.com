<cfsavecontent variable="request.response.body">
<cfoutput>

	<cfif isSimpleValue( errorResponse )>

		You poem has been saved.

	<cfelse>

		#e( errorResponse.message )#

	</cfif>

</cfoutput>
</cfsavecontent>
