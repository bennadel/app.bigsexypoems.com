<cfsavecontent variable="request.response.body">
<cfoutput>

	<div dtodzq class="dtodzq">

		<cfif share.noteHtml.len()>

			<section>
				#share.noteHtml#
			</section>

			<hr class="uiRule" />

		</cfif>

		<article>

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

	</div>

</cfoutput>
</cfsavecontent>
