<cfsavecontent variable="request.response.body">
<cfoutput>

	<article b4oxpm class="b4oxpm uiReadableWidth">

		<h1>
			#e( title )#
		</h1>

		<nav aria-labelledby="#ui.nextFieldId()#" class="uiPageNav">
			<span id="#ui.fieldId()#">
				Legal:
			</span>
			<ul>
				<li>
					<a #ui.attrHref( "marketing.legal.termsOfService" )#>Terms of Service</a>
				</li>
				<li>
					<a #ui.attrHref( "marketing.legal.privacyPolicy" )#>Privacy Policy</a>
				</li>
			</ul>
		</nav>

		<h2>
			What We Collect
		</h2>

		<p>
			We collect the following information: your email address (required for login), an optional display name, your IP address (via server logs), content you create (such as poems), and session cookies for authentication.
		</p>

		<h2>
			How We Use It
		</h2>

		<p>
			Your information is used to operate the service: to authenticate you, store your content, and display shared content. We only send emails to deliver magic-link login codes. We do not send marketing or promotional emails.
		</p>

		<h2>
			Third-Party Services
		</h2>

		<p>
			We use Cloudflare for content delivery and anti-bot protection (Turnstile). Cloudflare may collect standard web analytics at the network level.
		</p>

		<p>
			We use Bugsnag for error tracking. When an error occurs during your use of the service, technical data such as your IP address, browser, and user agent may be temporarily logged. This data is automatically deleted within a few weeks.
		</p>

		<p>
			We use the Datamuse API to provide rhymes, synonyms, definitions, and syllable counts. Individual words you enter may be sent to Datamuse for these lookups. No personal information is shared with Datamuse.
		</p>

		<p>
			We do not use any other third-party analytics or tracking services.
		</p>

		<h2>
			Data Sharing
		</h2>

		<p>
			We do not sell or share your personal data with third parties, except as required by law.
		</p>

		<h2>
			Data Retention and Deletion
		</h2>

		<p>
			Your data is stored for as long as you have an account. You can delete your account at any time to permanently remove all of your data.
		</p>

		<h2>
			Children's Privacy
		</h2>

		<p>
			We do not knowingly collect personal information from children under 13. If you believe a child under 13 has provided us with personal information, please contact us so we can remove it.
		</p>

		<h2>
			Contact
		</h2>

		<p>
			Privacy questions can be sent to <a href="mailto:#e4a( systemEmail )#">#e( systemEmail )#</a>.
		</p>

	</article>

</cfoutput>
</cfsavecontent>
