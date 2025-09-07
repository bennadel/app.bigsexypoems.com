<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<p>
			#e( message )#
		</p>

		<hr class="uiRule" />

		<p>
			In the meantime, you can <a #ui.attrHref( "member" )#>return to the homepage</a>.
		</p>

	</article>

</cfoutput>
</cfsavecontent>
