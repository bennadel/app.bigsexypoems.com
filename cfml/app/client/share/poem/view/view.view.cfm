<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiFlow">

		<h1>
			#encodeForHtml( title )#
		</h1>

		<pre>#encodeForHtml( poem.content )#</pre>

		<p>
			&mdash; <em>#encodeForHtml( user.name )#</em>
		</p>

	</article>

	<hr style="margin-top: 50px ;">

	<p style="font-size: 14px ;">
		Want to share your own poems? <a href="/">Sign-up for a free account</a>.
	</p>

</cfoutput>
</cfsavecontent>
