<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiFlow">

		<h1>
			#encodeForHtml( title )#
		</h1>

		<p>
			#encodeForHtml( errorMessage )#
		</p>

		<p>
			<a #ui.attrHref( "auth" )#>Back to Login</a>
		</p>

	</article>

</cfoutput>
</cfsavecontent>
