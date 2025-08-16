<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiFlow">

		<h1>
			#encodeForHtml( title )#
		</h1>

		<p>
			#encodeForHtml( message )#
		</p>

		<hr class="uiRule" />

		<p>
			In the meantime, you can <a #ui.attrHref( "member" )#>return to the homepage</a>.
		</p>

	</article>

</cfoutput>
</cfsavecontent>
