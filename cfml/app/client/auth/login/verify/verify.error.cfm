<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiFlow">

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
