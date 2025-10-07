<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( config.site.name )# Login
		</h1>

		<p>
			You can use your email address to log in or sign up. A verification link will be sent to your email address so we can verify your account. This verification link will be sent from <mark>#e( fromEmail )#</mark> (during the beta).
		</p>

		<cfmodule
			template="/client/_shared/tag/errorMessage.cfm"
			message="#errorMessage#">
		</cfmodule>

		<form method="post" action="#request.postBackAction#" x-prevent-double-submit>
			<cfmodule template="/client/_shared/tag/xsrf.cfm" />
			<input type="hidden" name="timezoneOffsetInMinutes" x-data="TzOffsetController" />

			<div class="uiField">
				<label for="form--email" class="uiField_label">
					Email:
				</label>
				<div class="uiField_content">
					<input
						id="form--email"
						type="text"
						inputmode="email"
						name="email"
						value="#e4a( form.email )#"
						placeholder="ben@example.com"
						maxlength="75"
						autocapitalize="off"
						autocomplete="email"
						class="uiInput"
					/>
				</div>
			</div>
			<div class="uiField">
				<label for="form--betaPassword" class="uiField_label">
					Beta Invitation Code:
				</label>
				<div class="uiField_content">
					<p class="uiField_description">
						During the development phase of this application, <strong><mark>new users</mark></strong> need a special invitation code in order to log in. If you're keen to try BigSexyPoems, just reach out using <a href="https://linkedin.com/in/bennadel" target="_blank">LinkedIn</a> or <a href="https://www.bennadel.com/contact/contact-ben-nadel.htm" target="_blank">my blog</a>.
					</p>

					<input
						id="form--betaPassword"
						type="password"
						name="betaPassword"
						maxlength="30"
						class="uiInput"
					/>
				</div>
			</div>

			<!--- For ease of development, Turnstile only required in production. --->
			<cfif config.turnstile.isEnabled>
				<div class="uiField">
					<label for="form--email" class="uiField_label">
						Human or Bot:
					</label>
					<div class="uiField_content">
						<!---
							Turnstile challenge.
							--
							Note: this div must be inside the FORM as it will inject a hidden form
							field as a child element (which must be submission to the server).
						--->
						<div
							data-sitekey="#e4a( config.turnstile.client.apiKey )#"
							r9fbqd class="cf-turnstile">
						</div>

						<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
					</div>
				</div>
			</cfif>

			<div class="uiFormButtons">
				<button type="submit" class="uiButton isSubmit">
					Log In or Sign Up
				</button>
				<span r9fbqd class="playground-cta">
					Or, <a #ui.attrHref( "playground" )#>try the composer</a> without an account &rarr;
				</span>
			</div>
		</form>

	</article>

</cfoutput>
</cfsavecontent>
