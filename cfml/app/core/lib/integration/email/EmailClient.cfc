component hint = "I provide an abstraction for sending email." {

	// Define properties for dependency-injection.
	property name="site" ioc:get="config.site";
	property name="systemEmail" ioc:get="config.systemEmail";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I send the given mail specification.
	*/
	public void function sendMail(
		required string to,
		required string subject,
		required string body,
		required string tag,
		string from = systemEmail.addressWithUser,
		string type = "html",
		boolean async = false
		) {

		cfmail(
			to = to,
			from = from,
			subject = subject,
			type = type,
			spoolEnable = async
			) {

			cfmailparam(
				name = "X-PM-Tag",
				value = tag
			);

			writeOutput( body );
		}

	}

}
