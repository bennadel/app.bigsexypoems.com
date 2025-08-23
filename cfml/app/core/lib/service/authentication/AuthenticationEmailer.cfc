component {

	// Define properties for dependency-injection.
	property name="emailClient" ioc:type="core.lib.integration.email.EmailClient";
	property name="site" ioc:get="config.site";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I send the magic link email.
	*/
	public void function sendMagicLink(
		required string email,
		required string subject,
		required string loginUrl,
		required string loginExpiration
		) {

		var partial = {
			subject: subject,
			teaser: "",
			site: {
				name: site.name,
				publicUrl: site.url
			},
			verification: {
				url: loginUrl,
				expiration: loginExpiration
			}
		};

		savecontent variable = "local.body" {
			include "/email/loginRequest.cfm";
		}

		emailClient.sendMail(
			to = email,
			subject = partial.subject,
			body = body,
			tag = "LoginRequest"
		);

	}

}
