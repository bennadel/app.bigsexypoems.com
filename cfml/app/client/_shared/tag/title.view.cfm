<cfoutput>
	<title>
		#encodeForHtml( request.response.title )#

		<!--- Don't double-up on the main title. --->
		<cfif ( request.response.title != config.site.name )>
			&mdash; #encodeForHtml( config.site.name )#
		</cfif>
	</title>
</cfoutput>
