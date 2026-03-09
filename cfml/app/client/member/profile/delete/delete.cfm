<cfscript>

	// Define properties for dependency-injection.
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	sessionCookies = request.ioc.get( "core.lib.service.session.SessionCookies" );
	ui = request.ioc.get( "core.lib.web.UI" );
	userAccess = request.ioc.get( "core.lib.service.user.UserAccess" );
	userService = request.ioc.get( "core.lib.service.user.UserService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.isConfirmed" type="boolean" default=false;

	partial = getPartial( request.authContext );
	user = partial.user;
	title = "Delete Account";
	errorResponse = "";

	request.response.title = title;
	request.response.breadcrumbs.append( "Delete Account" );

	if ( request.isPost ) {

		try {

			if ( ! form.isConfirmed ) {

				throw( type = "App.ConfirmationRequired" );

			}

			userService.delete(
				authContext = request.authContext,
				id = user.id
			);
			// The user cascade will already take care of deleting all of the sessions
			// associated with the user. That will implicitly remove any meaning from the
			// cookies that they currently have. But, as a final cleanup step, let's
			// remove the session cookies the user had for the current session.
			sessionCookies.deleteCookie();

			router.goto([
				event: "auth.logout.success",
				flash: "your.user.account.deleted"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./delete.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial( required struct authContext ) {

		var context = userAccess.getContext( authContext, authContext.user.id, "canDelete" );
		var user = context.user;

		return {
			user
		};

	}

</cfscript>
