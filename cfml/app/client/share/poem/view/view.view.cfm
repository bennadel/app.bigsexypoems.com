<cfsavecontent variable="request.response.body">
<cfoutput>

	<cfif share.noteHtml.len()>

		<div class="uiFlow">
			#share.noteHtml#

			<hr class="uiRule" />
		</div>

	</cfif>

	<article class="uiFlow">

		<h1>
			#e( title )#
		</h1>

		<pre>#e( poem.content )#</pre>

		<p>
			&mdash; <em>#e( user.name )#</em>
		</p>

	</article>

	<hr style="margin-top: 50px ;">

	<p style="font-size: 14px ;">
		Want to share your own poems? <a href="/">Sign-up for a free account</a>.
	</p>

</cfoutput>
</cfsavecontent>
