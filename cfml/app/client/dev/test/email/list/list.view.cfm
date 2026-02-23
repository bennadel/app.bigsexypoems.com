<cfsavecontent variable="request.response.body">
<cfoutput>

	<h1>
		#e( title )#
	</h1>

	<ul>
		<li>
			<a #ui.attrHref( "dev.test.email.view", "templateID", "loginRequest" )#>Login Request</a>
		</li>
	</ul>

</cfoutput>
</cfsavecontent>
