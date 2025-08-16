component {

	// Define properties for dependency-injection.
	// property name="errorUtilities" ioc:type="core.lib.util.ErrorUtilities";
	property name="logger" ioc:type="core.lib.util.Logger";
	property name="router" ioc:type="core.lib.web.Router";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I translate the given flash token and data into a user-friendly flash response which
	* contains a message and optional link.
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
			case "account.profile.updated":
				return asResponse( "Your profile has been updated." );
			break;
			case "account.session.deleted":
				return asResponse( "Your session has been ended." );
			break;
			case "account.session.deletedAll":
				return asResponse( "All of your sessions have been ended. You've been logged-out across all of your devices." );
			break;
			case "feedback.conceptBoard.comment.created":
				return asResponse( "Your comment has been created." );
			break;
			case "feedback.conceptBoard.comment.deleted":
				return asResponse( "Your comment has been deleted." );
			break;
			case "feedback.conceptBoard.comment.updated":
				return asResponse( "Your comment has been updated." );
			break;
			case "member.client.created":
				return asResponse( "Your client has been created." );
				// return asResponse(
				// 	message = "Your client has been created.",
				// 	linkIf = flashID,
				// 	linkText = "View client",
				// 	linkHref = router.urlForParts( "member.client.view", "clientID", flashID )
				// );
			break;
			case "member.client.deleted":
				return asResponse( "Your client has been deleted." );
			break;
			case "member.client.updated":
				return asResponse( "Your client has been updated." );
			break;
			case "member.conceptBoard.view.comment.created":
				return asResponse( "Your comment has been created." );
			break;
			case "member.conceptBoard.view.comment.deleted":
				return asResponse( "Your comment has been deleted." );
			break;
			case "member.conceptBoard.view.comment.updated":
				return asResponse( "Your comment has been created." );
			break;
			case "member.conceptBoard.created":
				return asResponse( "Your board has been created." );
			break;
			case "member.conceptBoard.view.deleted":
				return asResponse( "Your board has been deleted." );
			break;
			case "member.conceptBoard.view.item.created":
				return asResponse( "Your item has been created." );
			break;
			case "member.conceptBoard.view.item.deleted":
				return asResponse( "Your item has been deleted." );
			break;
			case "member.conceptBoard.view.item.updated":
				return asResponse( "Your item has been updated." );
			break;
			case "member.conceptBoard.joined":
				return asResponse( "You joined the board." );
			break;
			case "member.conceptBoard.view.left":
				return asResponse( "You left the board." );
			break;
			case "member.conceptBoard.view.section.created":
				return asResponse( "Your section has been created." );
			break;
			case "member.conceptBoard.view.section.deleted":
				return asResponse( "Your section has been deleted." );
			break;
			case "member.conceptBoard.view.section.updated":
				return asResponse( "Your section has been updated." );
			break;
			case "member.conceptBoard.view.share.created":
				return asResponse( "Your share link has been created." );
			break;
			case "member.conceptBoard.view.share.deleted":
				return asResponse( "Your share link has been deleted." );
			break;
			case "member.conceptBoard.view.share.updated":
				return asResponse( "Your share link has been updated." );
			break;
			case "member.conceptBoard.view.updated":
				return asResponse( "Your board has been updated." );
			break;
			case "member.team.invitation.created":
				return asResponse( "Your invitation has been created." );
			break;
			case "member.team.invitation.deleted":
				return asResponse( "Your invitation has been deleted." );
			break;
			case "member.team.membership.deleted":
				return asResponse( "Your membership has been deleted." );
			break;
			case "member.team.updated":
				return asResponse( "Your team has been updated." );
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

				return asResponse( "Huzzah!" );
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
