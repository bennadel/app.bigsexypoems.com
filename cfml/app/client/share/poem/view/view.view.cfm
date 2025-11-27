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

			<ul dtodzq class="lines">
				<cfloop array="#lines#" item="line">
					<li>
						#e( line )#<br />
					</li>
				</cfloop>
			</ul>

			<p dtodzq class="author">
				&mdash; <em>#e( user.name )#</em>
			</p>

		</article>

		<hr class="uiRule" style="margin-top: 50px ;">

		<p style="font-size: 14px ;">
			Want to share your own poems? <a href="/">Sign-up for a free account</a>.
		</p>

	</div>

	<!---
		Log viewing asynchronously (if the user is not the poem author - we don't want to
		log instances of the author testing the look-and-feel of the share experience).
		I'm performing this as a subsequent client-side form POST with a small delay in
		order to try and omit bot-based requests from share links that have been posted to
		a public forum.
	--->
	<cfif ( poem.userID != request.authContext.user.id )>

		<form
			hx-post="#router.urlForParts( 'share.poem.logViewing' )#"
			hx-trigger="load delay:2s"
			hx-swap="none"
			style="display: none ;">
			<cfmodule template="/client/_shared/tag/xsrf.cfm" />
		</form>

	</cfif>

</cfoutput>
</cfsavecontent>
