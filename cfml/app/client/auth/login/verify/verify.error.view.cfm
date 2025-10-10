<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<p>
			#e( errorMessage )#
		</p>

		<p>
			<a #ui.attrHref( "auth" )#>Back to Login</a>
		</p>

	</article>

</cfoutput>
</cfsavecontent>
