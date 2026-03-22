<cfsavecontent variable="request.response.body">
<cfoutput>

	<article wp6r31 class="wp6r31 uiReadableWidth">

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
			Agreement
		</h2>

		<p>
			By using #e( siteName )#, you agree to these terms. If you do not agree, please do not use the service. You must be at least 13 years old to use this service.
		</p>

		<h2>
			Your Content
		</h2>

		<p>
			You own everything you create on #e( siteName )#. By using the service, you grant us a limited license to store and display your content as needed to operate the service. This license ends when you delete your content or your account.
		</p>

		<p>
			If you share content via a public link, it will be viewable by anyone with that link. You are responsible for what you choose to share.
		</p>

		<h2>
			Acceptable Use
		</h2>

		<p>
			Do not use #e( siteName )# for anything illegal, to harass others, or to distribute harmful content. Violation of these rules may result in the immediate suspension or termination of your account without prior notice.
		</p>

		<h2>
			Account Deletion
		</h2>

		<p>
			You can delete your account at any time. Deletion permanently removes your data from the service.
		</p>

		<h2>
			No Warranty
		</h2>

		<p>
			#e( siteName )# is provided "as is" without warranties of any kind, express or implied. We make no guarantees about the availability, reliability, or fitness of the service for any particular purpose.
		</p>

		<h2>
			Limitation of Liability
		</h2>

		<p>
			#e( systemOwner )# is not liable for any damages arising from your use of the service, including but not limited to loss of data or content.
		</p>

		<h2>
			Indemnification
		</h2>

		<p>
			You agree to indemnify and hold #e( systemOwner )# harmless from any claims, damages, or expenses arising from your use of the service or content you create or share.
		</p>

		<h2>
			Severability
		</h2>

		<p>
			If any provision of these terms is found to be unenforceable, the remaining provisions will continue to apply.
		</p>

		<h2>
			Changes
		</h2>

		<p>
			These terms may be updated from time to time. Continued use of the service constitutes acceptance of any changes.
		</p>

		<h2>
			Contact
		</h2>

		<p>
			Questions about these terms can be sent to <a href="mailto:#e4a( systemEmail )#">#e( systemEmail )#</a>.
		</p>

	</article>

</cfoutput>
</cfsavecontent>
