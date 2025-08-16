<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiFlow">

		<h1>
			#encodeForHtml( title )#
		</h1>

		<p>
			A login request has been sent to the provided email address. It will contain a link that will complete the login workflow.
		</p>

		<p>
			<strong>Important:</strong> The link can only be used once; and, is only active for a few minutes.
		</p>

		<!--- Locally, provide convenience link to local SMTP server. --->
		<cfif localDevInbox.len()>
			<p>
				<a href="#localDevInbox#"><mark>Access Mailhog Server</mark></a>
			</p>
		</cfif>
		<cfif localDevLoginUrl.len()>
			<p>
				Or, <a href="#localDevLoginUrl#"><mark>use the login link directly</mark></a>
			</p>
		</cfif>

	</article>

</cfoutput>
</cfsavecontent>
