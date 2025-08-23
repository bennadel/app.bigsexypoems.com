component {

	// Define properties for dependency-injection.
	property name="logger" ioc:type="core.lib.util.Logger";
	property name="router" ioc:type="core.lib.web.Router";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I translate the given flash token and data into a user-friendly flash response which
	* contains a message and an optional link.
	* 
	* SECURITY: while the "flashToken" value is used only for control-flow, the
	* "flashData" value is used in the HTML rendering (of the optional link). Which means
	* that it is inherently an attack vector for reflected Cross-Size Scripting (XSS)
	* Attacks. As such, care must be taken when using the flashData in the output. As much
	* as possible try to sanitize the flashData before rendering it. For example,
	* "val(flashData)" will ensure that only numeric values are output.
	*/
	public struct function translate(
		required string flashToken,
		required string flashData
		) {

		var flashID = val( flashData );

		switch ( flashToken ) {
			// return asResponse(
			// 	message = "Your client has been created.",
			// 	linkIf = flashID,
			// 	linkText = "View client",
			// 	linkHref = router.urlForParts( "member.client.view", "clientID", flashID )
			// );
			case "your.poem.created":
				return asResponse( "Your poem has been created." );
			break;
			case "your.poem.deleted":
				return asResponse( "Your poem has been deleted." );
			break;
			case "your.poem.share.created":
				return asResponse( "Your share link has been created." );
			break;
			case "your.poem.share.allDeleted":
				return asResponse( "Your share links have been deleted." );
			break;
			case "your.poem.share.deleted":
				return asResponse( "Your share link has been deleted." );
			break;
			case "your.poem.updated":
				return asResponse( "Your poem has been updated." );
			break;
			case "your.session.deleted":
				return asResponse( "Your session has been ended." );
			break;
			case "your.session.allDeleted":
				return asResponse( "All of your sessions have been ended. You've been logged-out across all of your devices." );
			break;
			case "your.user.account.updated":
				return asResponse( "Your account has been updated." );
			break;
			default:
				// If anything got this far, we have a controller that's including a flash
				// that we haven't defined yet. Let's log it so that we can fix the flash
				// handling in a future update.
				logger.warning(
					"Flash token not supported.",
					{
						token: flashToken,
						data: flashData
					}
				);

				return asResponse( "Huzzah! The request was a success!" );
			break;
		}

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I construct a structured response from the given arguments.
	*/
	private struct function asResponse(
		required string message,
		boolean linkIf = false,
		string linkText = "",
		string linkHref = ""
		) {

		var result = {
			message: message,
			link: {
				exists: false
			}
		};

		if ( linkIf ) {

			if ( ! linkText.len() || ! linkHref.len() ) {

				throw( type = "FlashTranslator.InvalidLink" );

			}

			result.link.exists = true;
			result.link.text = linkText;
			result.link.href = linkHref;

		}

		return result;

	}

}
