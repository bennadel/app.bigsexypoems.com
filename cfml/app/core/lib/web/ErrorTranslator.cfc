component hint = "I help translate application errors into appropriate response codes and user-facing messages." {

	// Define properties for dependency-injection.
	property name="errorUtilities" ioc:type="core.lib.util.ErrorUtilities";
	property name="logger" ioc:type="core.lib.util.Logger";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I translate the given internal error objects into user-friendly error responses.
	* All of the embedded information is safe to show to the user.
	*/
	public struct function translate( required any error ) {

		// Some errors include metadata about why the error was thrown. These data-points
		// can be used to generate a more insightful message for the user.
		var metadata = errorUtilities.extractMetadataSafely( error.extendedInfo );

		switch ( error.type ) {
			case "App.BadRequest":
				return as400();
			break;
			case "App.ConfirmationRequired":
				return as403({
					type: error.type,
					message: "Please confirm that you understand the implications of your action."
				});
			break;
			case "App.Forbidden":
				return as403();
			break;
			case "App.InternalOnly":
				return as403({
					type: error.type,
					message: "Sorry, you've attempted to use a feature that is currently in private beta. I'm hoping to start opening this up to a wider audience soon."
				});
			break;
			case "App.MethodNotAllowed":
				return as405();
			break;







			case "App.Model.Poem.Content.TooLong":
				return as422({
					type: error.type,
					message: "Your poem must be less than 3,000-characters."
				});
			break;
			case "App.Model.Poem.Content.SuspiciousEncoding":
				return as422({
					type: error.type,
					message: "Your poem contains a suspicious encoding of characters. Make sure that you're only using plain-text."
				});
			break;
			case "App.Model.Poem.Name.Empty":
				return as422({
					type: error.type,
					message: "Your poem name cannot be empty."
				});
			break;
			case "App.Model.Poem.Name.TooLong":
				return as422({
					type: error.type,
					message: "Your poem name must be less than 255-characters."
				});
			break;
			case "App.Model.Poem.Name.SuspiciousEncoding":
				return as422({
					type: error.type,
					message: "Your poem name contains a suspicious encoding of characters. Make sure that you're only using plain-text."
				});
			break;
			case "App.Model.Poem.NotFound":
				return as404({
					type: error.type,
					message: "The poem you requested cannot be found."
				});
			break;
			case "App.Model.PoemShare.Share.NotFound":
				return as404({
					type: error.type,
					message: "The poem share you requested cannot be found."
				});
			break;
			case "App.OneTimeToken.Invalid":
				return as403({
					type: error.type,
					message: "Your request has expired."
				});
			break;
			case "App.RateLimit.TooManyRequests":
				return as429({
					type: error.type
				});
			break;









			case "App.Model.Client.DescriptionMarkdown.Unsafe":
				return asModelMarkdownUnsafe( error, "client description", metadata );
			break;
			case "App.Model.Client.Name.Empty":
				return asModelStringEmpty( error, "client name" );
			break;
			case "App.Model.Client.Name.SuspiciousEncoding":
				return asModelStringSuspiciousEncoding( error, "client name" );
			break;
			case "App.Model.Client.Name.TooLong":
				return asModelStringTooLong( error, "client name", metadata );
			break;
			case "App.Model.Client.NotFound":
				return asModelNotFound( error, "client" );
			break;
			case "App.Model.Client.WebsiteUrl.Invalid":
				return as422({
					type: error.type,
					message: "Your website url must start with either ""http://"" or ""https://""."
				});
			break;
			case "App.Model.Client.WebsiteUrl.TooLong":
				return asModelStringTooLong( error, "website url", metadata );
			break;
			case "App.Model.ConceptBoard.DescriptionMarkdown.Unsafe":
				return asModelMarkdownUnsafe( error, "board description", metadata );
			break;
			case "App.Model.ConceptBoard.Name.Empty":
				return asModelStringEmpty( error, "board name" );
			break;
			case "App.Model.ConceptBoard.Name.SuspiciousEncoding":
				return asModelStringSuspiciousEncoding( error, "board name" );
			break;
			case "App.Model.ConceptBoard.Name.TooLong":
				return asModelStringTooLong( error, "board name", metadata );
			break;
			case "App.Model.ConceptBoard.NotFound":
				return asModelNotFound( error, "board" );
			break;
			case "App.Model.ConceptBoard.Comment.ContentMarkdown.Empty":
				return asModelStringEmpty( error, "comment" );
			break;
			case "App.Model.ConceptBoard.Comment.ContentMarkdown.Unsafe":
				return asModelMarkdownUnsafe( error, "comment", metadata );
			break;
			case "App.Model.ConceptBoard.Comment.NotFound":
				return asModelNotFound( error, "comment" );
			break;
			case "App.Model.ConceptBoard.Item.ClientFilename.Empty":
				return asModelStringEmpty( error, "item filename" );
			break;
			case "App.Model.ConceptBoard.Item.ClientFilename.TooLong":
				return asModelStringTooLong( error, "item filename", metadata );
			break;
			case "App.Model.ConceptBoard.Item.DescriptionMarkdown.Unsafe":
				return asModelMarkdownUnsafe( error, "item description", metadata );
			break;
			case "App.Model.ConceptBoard.Item.Name.Empty":
				return asModelStringEmpty( error, "item name" );
			break;
			case "App.Model.ConceptBoard.Item.Name.SuspiciousEncoding":
				return asModelStringSuspiciousEncoding( error, "item name" );
			break;
			case "App.Model.ConceptBoard.Item.Name.TooLong":
				return asModelStringTooLong( error, "item name" );
			break;
			case "App.Model.ConceptBoard.Item.NotFound":
				return asModelNotFound( error, "item" );
			break;
			case "App.Model.ConceptBoard.Section.DescriptionMarkdown.Unsafe":
				return asModelMarkdownUnsafe( error, "section description", metadata );
			break;
			case "App.Model.ConceptBoard.Section.Name.Empty":
				return asModelStringEmpty( error, "section name" );
			break;
			case "App.Model.ConceptBoard.Section.Name.SuspiciousEncoding":
				return asModelStringSuspiciousEncoding( error, "section name" );
			break;
			case "App.Model.ConceptBoard.Section.Name.TooLong":
				return asModelStringTooLong( error, "section name", metadata );
			break;
			case "App.Model.ConceptBoard.Section.NotFound":
				return asModelNotFound( error, "section" );
			break;
			case "App.Model.ConceptBoard.Share.Name.Empty":
				return asModelStringEmpty( error, "share name" );
			break;
			case "App.Model.ConceptBoard.Share.Name.TooLong":
				return asModelStringTooLong( error, "share name", metadata );
			break;
			case "App.Model.ConceptBoard.Share.Name.SuspiciousEncoding":
				return asModelStringSuspiciousEncoding( error, "share name" );
			break;
			case "App.Model.ConceptBoard.Share.NotFound":
				return asModelNotFound( error, "share" );
			break;
			case "App.Model.OneTimeToken.NotFound":
				return as400({
					type: error.type,
					message: "Your request has expired, please try again."
				});
			break;
			case "App.Model.Session.NotFound":
				return asModelNotFound( error, "session" );
			break;
			case "App.Model.User.Account.NotFound":
				return asModelNotFound( error, "account" );
			break;
			case "App.Model.User.Email.Empty":
				return asModelStringEmpty( error, "email address" );
			break;
			case "App.Model.User.Email.Example":
				return as422({
					type: error.type,
					message: "Your email address is using an unsupported domain. Please choose another email address."
				});
			break;
			case "App.Model.User.Email.Invalid":
				return as422({
					type: error.type,
					message: "Please enter a valid email address."
				});
			break;
			case "App.Model.User.Email.SuspiciousEncoding":
				return asModelStringSuspiciousEncoding( error, "email address" );
			break;
			case "App.Model.User.Email.TooLong":
				return asModelStringTooLong( error, "email address", metadata );
			break;
			case "App.Model.User.Name.Empty":
				return asModelStringEmpty( error, "name" );
			break;
			case "App.Model.User.Name.SuspiciousEncoding":
				return asModelStringSuspiciousEncoding( error, "name" );
			break;
			case "App.Model.User.Name.TooLong":
				return asModelStringTooLong( error, "name", metadata );
			break;
			case "App.Model.User.NotFound":
				return asModelNotFound( error, "user" );
			break;
			case "App.Model.User.Timezone.NotFound":
				return asModelNotFound( error, "timezone" );
			break;
			case "App.NotFound":
				return as404();
			break;
			case "App.Routing.InvalidEvent":
				return as404({
					type: error.type
				});
			break;
			case "App.SessionService.VerifyLogin.Expired":
			case "App.SessionService.VerifyLogin.SignatureMismatch":
				return as403({
					type: error.type,
					message: "Your login link has expired. Please try logging-in again."
				});
			break;
			case "App.ServerError":
				return as500();
			break;
			case "App.TooManyRequests":
				return as429();
			break;
			case "App.Unauthorized":
				return as401();
			break;
			case "App.UnprocessableEntity":
				return as422();
			break;
			case "App.Xsrf.Mismatch":
			case "App.Xsrf.MissingChallenge":
			case "App.Xsrf.MissingCookie":
			return as400({
					type: error.type,
					message: "Your form has expired. Please try submitting it again."
				});
			break;
			// Anything not handled by an explicit case becomes a generic 500 response.
			default:
				// If this is a domain error, it should have been handled by an explicit
				// switch-case above. Let's log it so that we can fix the error handling
				// in a future update.
				// --
				// Note: Using toString() in order to fix an edge-case in which Adobe
				// ColdFusion throws some errors as objects.
				if ( toString( error.type ).listFirst( "." ) == "App" ) {

					logger.info( "Error not handled by case in ErrorTranslator.", error );

				}

				return as500();
			break;
		}

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I generate a 400 response object for the given error attributes.
	*/
	private struct function as400( struct errorAttributes = {} ) {

		return getGeneric400Response().append( errorAttributes );

	}


	/**
	* I generate a 401 response object for the given error attributes.
	*/
	private struct function as401( struct errorAttributes = {} ) {

		return getGeneric401Response().append( errorAttributes );

	}


	/**
	* I generate a 403 response object for the given error attributes.
	*/
	private struct function as403( struct errorAttributes = {} ) {

		return getGeneric403Response().append( errorAttributes );

	}


	/**
	* I generate a 404 response object for the given error attributes.
	*/
	private struct function as404( struct errorAttributes = {} ) {

		return getGeneric404Response().append( errorAttributes );

	}


	/**
	* I generate a 405 response object for the given error attributes.
	*/
	private struct function as405( struct errorAttributes = {} ) {

		return getGeneric405Response().append( errorAttributes );

	}


	/**
	* I generate a 422 response object for the given error attributes.
	*/
	private struct function as422( struct errorAttributes = {} ) {

		return getGeneric422Response().append( errorAttributes );

	}


	/**
	* I generate a 429 response object for the given error attributes.
	*/
	private struct function as429( struct errorAttributes = {} ) {

		return getGeneric429Response().append( errorAttributes );

	}


	/**
	* I generate a 500 response object for the given error attributes.
	*/
	private struct function as500( struct errorAttributes = {} ) {

		return getGeneric500Response().append( errorAttributes );

	}


	/**
	* I generate a 422 response object for the given model issue.
	*/
	private struct function asModelMarkdownUnsafe(
		required any error,
		required string fieldName,
		required struct metadata
		) {

		return as422({
			type: error.type,
			message: "Your #fieldName# contains HTML that isn't allowed in the current context. The following elements need to be removed: [#metadata.tagNames#]."
		});

	}


	/**
	* I generate a 404 response object for the given model issue.
	*/
	private struct function asModelNotFound(
		required any error,
		required string modelName
		) {

		return as404({
			type: error.type,
			message: "The #modelName# you requested cannot be found."
		});

	}


	/**
	* I generate a 422 response object for the given model issue.
	*/
	private struct function asModelStringEmpty(
		required any error,
		required string fieldName
		) {

		return as422({
			type: error.type,
			message: "Your #fieldName# cannot be empty."
		});

	}


	/**
	* I generate a 422 response object for the given model issue.
	*/
	private struct function asModelStringSuspiciousEncoding(
		required any error,
		required string fieldName
		) {

		return as422({
			type: error.type,
			message: "Your #fieldName# contains a suspicious encoding of characters. Make sure that you are only using plain-text."
		});

	}


	/**
	* I generate a 422 response object for the given model issue.
	*/
	private struct function asModelStringTooLong(
		required any error,
		required string fieldName,
		required struct metadata
		) {

		return as422({
			type: error.type,
			message: "Your #fieldName# must be less than #metadata.maxLength#-characters."
		});

	}


	/**
	* I return the generic "400 Bad Request" response.
	*/
	private struct function getGeneric400Response() {

		return {
			statusCode: 400,
			statusText: "Bad Request",
			type: "App.BadRequest",
			title: "Bad Request",
			message: "Your request cannot be processed in its current state. Please validate the information in your request and try submitting it again."
		};

	}


	/**
	* I return the generic "401 Unauthorized" response.
	*/
	private struct function getGeneric401Response() {

		return {
			statusCode: 401,
			statusText: "Unauthorized",
			type: "App.Unauthorized",
			title: "Unauthorized",
			message: "Please login and try submitting your request again."
		};

	}


	/**
	* I return the generic "403 Forbidden" response.
	*/
	private struct function getGeneric403Response() {

		return {
			statusCode: 403,
			statusText: "Forbidden",
			type: "App.Forbidden",
			title: "Forbidden",
			message: "Your request is not permitted at this time."
		};

	}


	/**
	* I return the generic "404 Not Found" response.
	*/
	private struct function getGeneric404Response() {

		return {
			statusCode: 404,
			statusText: "Not Found",
			type: "App.NotFound",
			title: "Page Not Found",
			message: "The resource that you requested either doesn't exist or has been moved to a new location."
		};

	}


	/**
	* I return the generic "405 Method Not Allowed" response.
	*/
	private struct function getGeneric405Response() {

		return {
			statusCode: 405,
			statusText: "Method Not Allowed",
			type: "App.MethodNotAllowed",
			title: "Method Not Allowed",
			message: "Your request cannot be processed with the given HTTP method."
		};

	}


	/**
	* I return the generic "422 Unprocessable Entity" response.
	*/
	private struct function getGeneric422Response() {

		return {
			statusCode: 422,
			statusText: "Unprocessable Entity",
			type: "App.UnprocessableEntity",
			title: "Unprocessable Entity",
			message: "Your request cannot be processed in its current state. Please validate the information in your request and try submitting it again."
		};

	}


	/**
	* I return the generic "429 Too Many Requests" response.
	*/
	private struct function getGeneric429Response() {

		return {
			statusCode: 429,
			statusText: "Too Many Requests",
			type: "App.TooManyRequests",
			title: "Too Many Requests",
			message: "Your request has been rejected due to rate limiting. Please wait a few minutes and then try submitting your request again."
		};

	}


	/**
	* I return the generic "500 Server Error" response.
	*/
	private struct function getGeneric500Response() {

		return {
			statusCode: 500,
			statusText: "Server Error",
			type: "App.ServerError",
			title: "Something Went Wrong",
			message: "Sorry, something seems to have gone wrong while handling your request. I'll see if I can figure out what happened and fix it."
		};

	}

}
