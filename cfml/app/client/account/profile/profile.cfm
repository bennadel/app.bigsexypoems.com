<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	userModel = request.ioc.get( "core.lib.model.user.UserModel" );
	userService = request.ioc.get( "core.lib.service.user.UserService" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.name" type="string" default="";

	partial = getPartial( request.authContext );
	user = partial.user;
	title = "Profile";
	errorResponse = "";

	request.response.title = title;
	request.response.activeNav = "account.profile";

	// Initialize form.
	if ( ! form.submitted ) {

		form.name = user.name;

	}

	// Process form.
	if ( form.submitted ) {

		try {

			userService.updateUser(
				authContext = request.authContext,
				userID = request.authContext.user.id,
				userName = form.name
			);

			router.goto([
				event: "account.profile",
				flash: "account.profile.updated"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./profile.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial( required struct authContext ) {

		return {
			user: authContext.user
		};

	}

</cfscript>
