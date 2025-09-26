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

	<!---
		Log viewing asynchronously. I'm doing this as a subsequent client-side form POST
		with a small delay to try and omit bot-based requests from share links that have
		been posted to a public forum.
	--->
	<form
		hx-post="#router.urlForParts( 'share.poem.logViewing' )#"
		hx-trigger="load delay:2s"
		hx-swap="none"
		style="display: none ;">
		<cfmodule template="/client/_shared/tag/xsrf.cfm">
	</form>

</cfoutput>
</cfsavecontent>
