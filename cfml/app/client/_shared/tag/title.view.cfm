<cfoutput>
	<title>
		#e( request.response.title )#

		<!--- Don't double-up on the main title. --->
		<cfif ( request.response.title != config.site.name )>
			&mdash; #e( config.site.name )#
		</cfif>
	</title>
</cfoutput>
