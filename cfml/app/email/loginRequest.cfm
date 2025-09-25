
<!--- Import custom tag libraries. --->
<cfimport prefix="core" taglib="./dsl/core/" />
<cfimport prefix="html" taglib="./dsl/core/html/" />

<!--- Import application custom tag libraries. --->
<cfimport prefix="app" taglib="./tags/" />

<!--- // ------------------------------------------------------------------------- // --->
<!--- // ------------------------------------------------------------------------- // --->

<!--- For safety and documentation, outline the expected variables. --->
<cfparam name="partial.subject" type="string" />
<cfparam name="partial.teaser" type="string" />
<cfparam name="partial.site.name" type="string" />
<cfparam name="partial.site.publicUrl" type="string" />
<cfparam name="partial.verification.url" type="string" />
<cfparam name="partial.verification.expiration" type="string" />

<core:Email
	subject="#partial.subject#"
	teaser="#partial.teaser#">
	<core:Provide name="site.name" value="#partial.site.name#" />
	<core:Provide name="site.publicUrl" value="#partial.site.publicUrl#" />
	<app:Body>
		<cfoutput>

			<html:h1 margins="none double">
				Login Request
			</html:h1>

			<html:p>
				Someone with your email address has requested a login URL for <html:strong>#encodeForHtml( partial.site.name )#</html:strong>. Please use the following button to verify the login (or sign-up) request:
			</html:p>

			<app:CallToAction href="#partial.verification.url#" margins="normal double">
				Log In Now &rarr;
			</app:CallToAction>

			<html:p>
				Or, <html:a href="#encodeForHtmlAttribute( partial.verification.url )#">use this link to log in</html:a> to the app.
			</html:p>

			<html:h2 margins="normal quarter" class="copy-size">
				Time-Sensitive URL
			</html:h2>

			<html:p>
				The login link can only be used once and is only valid for the next <html:strong>#encodeForHtml( partial.verification.expiration )#</html:strong>. If you need to generate another link, you can do so from within the app.
			</html:p>

		</cfoutput>
	</app:Body>
</core:Email>
